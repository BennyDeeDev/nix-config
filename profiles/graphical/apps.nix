{
  nixos = { ... }: {
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
  };

  homeManager = { pkgs, lib, ... }: {
    programs.brave.enable = true;
    programs.google-chrome.enable = pkgs.stdenv.isLinux;
    programs.keepassxc.enable = true;
    programs.obs-studio.enable = pkgs.stdenv.isLinux;

    home.packages = [
      pkgs.spotify
    ]
    ++ lib.optionals pkgs.stdenv.isLinux (
      with pkgs;
      [
        libnotify
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
      ]
    );
  };
}
