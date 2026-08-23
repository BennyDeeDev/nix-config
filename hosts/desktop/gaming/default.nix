{ jovian, nix-flatpak }:

let
  bottles = import ./bottles.nix;
  flatpak = import ./flatpak.nix { inherit nix-flatpak; };
  lsfg = import ./lsfg.nix;
  ludusavi = import ./ludusavi.nix;
  rclone = import ./rclone.nix;
  ryujinx = import ./ryujinx.nix;
  steam = import ./steam.nix;
  steam-rom-manager = import ./steam-rom-manager.nix;
in
{
  nixos = {
    imports = [
      jovian.nixosModules.jovian
      flatpak.nixos
      steam.nixos
    ];
  };

  homeManager = {
    imports = [
      bottles.homeManager
      flatpak.homeManager
      lsfg.homeManager
      ludusavi.homeManager
      rclone.homeManager
      ryujinx.homeManager
      steam.homeManager
      steam-rom-manager.homeManager
    ];
  };
}
