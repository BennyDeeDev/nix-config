{
  nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.cage = {
        enable = true;
        extraArguments = [ "-s" ];
        program = pkgs.writeShellScript "android-tv-waydroid-ui" ''
          attempts=0
          while ! ${lib.getExe pkgs.wlr-randr} --output HDMI-A-1 --mode 1920x1080@60 >/dev/null 2>&1; do
            if test "$attempts" -ge 30; then
              echo "Could not configure HDMI-A-1 for 1920x1080@60" >&2
              exit 1
            fi
            ${lib.getExe' pkgs.coreutils "sleep"} 1
            attempts=$((attempts + 1))
          done

          exec ${lib.getExe config.virtualisation.waydroid.package} show-full-ui
        '';
        user = "tv";
      };

      services.seatd.enable = true;

      systemd.services.cage-tty1.serviceConfig = {
        Restart = "on-failure";
        RestartSec = "2s";
        TimeoutStopSec = "5s";
      };

      users.users.tv = {
        extraGroups = [
          "audio"
          "input"
          "render"
          "seat"
          "video"
        ];
        home = "/var/lib/android-tv";
        isNormalUser = true;
        createHome = true;
      };
    };
}
