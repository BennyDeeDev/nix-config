{
  nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      users.users.kiosk = {
        isNormalUser = true;
        description = "Kiosk display session";
        home = "/home/kiosk";
        createHome = true;
        hashedPassword = "!";
      };

      programs.firefox = {
        enable = true;
        autoConfig = ''
          lockPref("layout.css.devPixelsPerPx", "1.5");
        '';
      };

      services.cage = {
        enable = true;
        restartIfChanged = true;
        user = "kiosk";
        program = pkgs.writeShellScript "firefox-kiosk" ''
          exec ${lib.getExe config.programs.firefox.finalPackage} \
            --kiosk \
            https://ha.benjaminderksen.com/nixos-lovelace/infrastructure
        '';
      };

      # Ignore only the Pi 3 HDMI remote's pointer device; keep the touchscreen
      # and real mouse input available.
      services.udev.extraRules = ''
        ACTION=="add|change", SUBSYSTEM=="input", ENV{ID_PATH}=="platform-3f902000.hdmi", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '';

      systemd.services = {
        "autovt@tty1".enable = false;
        "cage-tty1".serviceConfig.SupplementaryGroups = [ "input" ];
      };
    };
}
