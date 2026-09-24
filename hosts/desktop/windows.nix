{
  nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      systemctlExe = lib.getExe' config.systemd.package "systemctl";
      efibootmgrExe = lib.getExe pkgs.efibootmgr;
    in
    {
      systemd.services.windows-reboot = {
        description = "Set Windows as the next EFI boot target and reboot";
        serviceConfig = {
          Type = "oneshot";
          ExecStartPost = "${systemctlExe} reboot";
        };
        script = ''
          boot_number="$(${efibootmgrExe} |
            ${lib.getExe pkgs.gnugrep} -m1 -E \
              '^Boot[[:xdigit:]]{4}[*]?[[:space:]]+Windows Boot Manager([[:space:]]|$)' |
            ${lib.getExe' pkgs.coreutils "cut"} -c 5-8)"

          if [[ -z "$boot_number" ]]; then
            printf 'Windows Boot Manager EFI entry not found\n' >&2
            exit 1
          fi

          ${efibootmgrExe} --bootnext "$boot_number"
        '';
      };

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              action.lookup("unit") == "windows-reboot.service" &&
              action.lookup("verb") == "start" &&
              subject.user == "benjamin" &&
              subject.local &&
              subject.active) {
            return polkit.Result.YES;
          }
        });
      '';

      services.displayManager.sessionPackages = [
        (
          pkgs.makeDesktopItem {
            name = "windows";
            destination = "/share/wayland-sessions";
            desktopName = "Windows";
            comment = "Reboot to Windows Boot Manager";
            exec = "${systemctlExe} --system start windows-reboot.service";
            type = "Application";
            categories = [ "System" ];
            extraConfig = {
              "X-DesktopNames" = "Windows";
            };
          }
          // {
            providedSessions = [ "windows" ];
          }
        )
      ];
    };

  homeManager =
    { lib, osConfig, ... }:
    {
      xdg.desktopEntries.windows = {
        name = "Windows";
        exec = "${lib.getExe' osConfig.systemd.package "systemctl"} --system start windows-reboot.service";
        comment = "Reboot to Windows Boot Manager";
        icon = "system-reboot-symbolic";
        type = "Application";
        categories = [ "System" ];
        settings."X-DesktopNames" = "Windows";
      };
    };
}
