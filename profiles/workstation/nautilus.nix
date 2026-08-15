{ ... }:

{
  nixos = { ... }: {
    services.gvfs.enable = true;
    programs.gnome-disks.enable = true;
  };

  homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        nautilus
        baobab
        ffmpegthumbnailer
      ];

      xdg.mimeApps.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
    };
}
