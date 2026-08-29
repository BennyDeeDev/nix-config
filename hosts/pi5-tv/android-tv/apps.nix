{
  nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      waydroid = lib.getExe config.virtualisation.waydroid.package;
      waitForSession = pkgs.writeShellScript "android-tv-waydroid-session-ready" ''
        set -eu

        until ${waydroid} status | ${lib.getExe pkgs.gnugrep} -q "Session:.*RUNNING"; do
          ${lib.getExe' pkgs.coreutils "sleep"} 1
        done
      '';
      waitForPackageService = pkgs.writeShellScript "android-tv-waydroid-package-service-ready" ''
        set -eu

        until ${waydroid} app list 2>/dev/null | ${lib.getExe pkgs.gnugrep} -q "^packageName:"; do
          ${lib.getExe' pkgs.coreutils "sleep"} 1
        done
      '';
      installer = pkgs.writeShellScript "android-tv-install-apps" ''
        set -eu

        state_dir=/var/lib/android-tv/.local/share/waydroid/app-state
        ${lib.getExe' pkgs.coreutils "mkdir"} -p "$state_dir"

        package_installed() {
          ${waydroid} app list 2>/dev/null |
            ${lib.getExe pkgs.gnugrep} -Fqx "packageName: $1"
        }

        wait_for_package() {
          i=0
          while test "$i" -lt 60; do
            if package_installed "$1"; then
              return 0
            fi
            ${lib.getExe' pkgs.coreutils "sleep"} 1
            i=$((i + 1))
          done
          return 1
        }

        ${lib.concatMapStringsSep "\n" (app: ''
          marker="$state_dir/${app.packageName}-${toString app.versionCode}"

          if test -e "$marker" && package_installed ${lib.escapeShellArg app.packageName}; then
            :
          else
            ${waydroid} app install ${lib.escapeShellArg (toString app.apk)}

            if ! wait_for_package ${lib.escapeShellArg app.packageName}; then
              echo "Waydroid app was not installed: ${app.packageName}" >&2
              exit 1
            fi

            ${lib.getExe' pkgs.coreutils "touch"} "$marker"
          fi
        '') (lib.attrValues (import ../android-apks { inherit pkgs; }))}
      '';
    in
    {
      environment.etc."android-tv/install-apps".source = installer;

      systemd.user.services.android-tv-apps = {
        description = "Install Android TV applications";
        wantedBy = [ "default.target" ];
        unitConfig.ConditionUser = "tv";
        serviceConfig = {
          ExecStartPre = [
            waitForSession
            waitForPackageService
          ];
          ExecStart = installer;
          Restart = "on-failure";
          RestartSec = "5s";
          TimeoutStartSec = "5min";
          Type = "oneshot";
        };
      };
    };
}
