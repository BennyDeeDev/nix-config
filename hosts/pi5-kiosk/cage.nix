{
  nixos =
    { lib, pkgs, ... }:
    {
      users.users.kiosk = {
        isNormalUser = true;
        description = "Kiosk display session";
        home = "/home/kiosk";
        createHome = true;
        hashedPassword = "!";
      };

      programs.chromium = {
        enable = true;
        initialPrefs.partition.default_zoom_level.x = 2.223901085741545;
      };

      services.cage = {
        enable = true;
        restartIfChanged = true;
        user = "kiosk";
        program = pkgs.writeShellScript "chromium-kiosk" ''
          exec ${lib.getExe pkgs.chromium} \
            --kiosk \
            --no-first-run \
            --no-default-browser-check \
            https://ha.benjaminderksen.com
        '';
      };

      systemd.services."cage-tty1".serviceConfig.SupplementaryGroups = [ "input" ];
    };
}
