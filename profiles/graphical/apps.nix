{
  nixos =
    { pkgs, ... }:
    {
      programs = {
        localsend = {
          enable = true;
          openFirewall = true;
        };
      };
    };

  darwin = {
    homebrew = {
      enable = true;
      onActivation.cleanup = "uninstall";
      taps = [
        {
          name = "TheBoredTeam/boring-notch";
          trusted = true;
        }
      ];
      casks = [
        "boring-notch"
        "ghostty"
        "stats"
      ];
    };
  };

  homeManager = { pkgs, lib, ... }: {
    programs = {
      brave.enable = true;
      google-chrome.enable = true;
      keepassxc.enable = true;
      obs-studio.enable = true;
      swappy.enable = pkgs.stdenv.isLinux;
    };

    home.packages = [
      pkgs.spotify
    ]
    ++ lib.optionals pkgs.stdenv.isLinux (
      with pkgs;
      [
        adw-gtk3
        baobab
        grim
        libnotify
        gnome-themes-extra
        yaru-theme
        glib
        gsettings-desktop-schemas
        showtime
        gnome-calculator
        gnome-characters
        gnome-font-viewer
        gnome-logs
        gnome-system-monitor
        gnome-weather
        loupe
        papers
        rpi-imager
        simple-scan
        system-config-printer
        slurp
        wl-clipboard
        xdg-utils
        xdg-terminal-exec
      ]
    )
    ++ lib.optionals pkgs.stdenv.isDarwin (
      with pkgs;
      [
        appcleaner
        caffeine
        the-unarchiver
      ]
    );

  };
}
