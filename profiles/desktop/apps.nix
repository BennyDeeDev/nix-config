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

  homeManager =
    { pkgs, ... }:
    {
      programs = {
        obs-studio.enable = true;
        swappy.enable = true;
      };

      home.packages = with pkgs; [
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
      ];
    };
}
