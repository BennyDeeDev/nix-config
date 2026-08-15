let
  nas = import ../../modules/nas.nix;
in
{
  nixos = {
    imports = [ nas.nixos ];

    my.nas = {
      uid = 1000;
      gid = 100;
      shares = [
        "Homelab"
        "Benjamin"
        "Ludusavi"
        "Restic"
      ];
    };
  };

  homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      xdg.configFile."gtk-3.0/bookmarks".text = lib.mkAfter ''
        file:///mnt/nas/benjamin NAS - Benjamin
        file:///mnt/nas/homelab NAS - Homelab
        file:///mnt/nas/ludusavi NAS - Ludusavi
        file:///mnt/nas/restic NAS - Restic
      '';
    };
}
