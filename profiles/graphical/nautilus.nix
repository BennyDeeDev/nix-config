{
  nixos = { ... }: {
    services.gvfs.enable = true;
  };

  homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        nautilus
        ffmpegthumbnailer
      ];
    };
}
