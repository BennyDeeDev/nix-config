{ nix-flatpak }:

let
  bottles = import ./bottles.nix { };
  flatpak = import ./flatpak.nix { inherit nix-flatpak; };
  fonts = import ./fonts.nix { };
  gamescope = import ./gamescope.nix { };
  lsfg = import ./lsfg.nix { };
  ludusavi = import ./ludusavi.nix { };
  mangohud = import ./mangohud.nix { };
  rclone = import ./rclone.nix { };
  ryujinx = import ./ryujinx.nix { };
  steam = import ./steam.nix { };
  steam-rom-manager = import ./steam-rom-manager.nix { };
in
{
  nixos = {
    imports = [
      flatpak.nixos
      gamescope.nixos
      steam.nixos
    ];
  };

  homeManager = {
    imports = [
      bottles.homeManager
      flatpak.homeManager
      fonts.homeManager
      lsfg.homeManager
      ludusavi.homeManager
      mangohud.homeManager
      rclone.homeManager
      ryujinx.homeManager
      steam-rom-manager.homeManager
    ];
  };
}
