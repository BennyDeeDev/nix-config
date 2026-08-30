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
      androidTv = pkgs.writeShellScript "android-tv-waydroid-ui" ''
        set -eu

        ${lib.getExe pkgs.wlr-randr} --output HDMI-A-1 --mode 1920x1080@60Hz
        exec ${waydroid} show-full-ui
      '';
    in
    {
      services.cage = {
        enable = true;
        extraArguments = [ "-s" ];
        program = androidTv;
        user = "tv";
      };

      services.seatd.enable = true;

      systemd.services.cage-tty1 = {
        after = [ "waydroid-container.service" ];
        wants = [ "waydroid-container.service" ];
      };

      systemd.services.cage-tty1.serviceConfig = {
        Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1001/bus";
        ExecStop = "-${waydroid} session stop";
        Restart = "on-failure";
        RestartSec = "2s";
        TimeoutStopSec = "30s";
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
