{ ... }:

{
  nixos = { pkgs, ... }: {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.dconf.enable = true;
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };

  homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        wl-clipboard
        grim
        slurp
        xwayland-satellite
        adw-gtk3
        gnome-themes-extra
        yaru-theme
        glib
        gsettings-desktop-schemas
        xdg-utils
        xdg-terminal-exec
      ];

      programs.swappy.enable = true;
    };
}
