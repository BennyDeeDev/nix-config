inputs@{
  disko,
  nix-flatpak,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  gaming = import ./gaming { inherit nix-flatpak; };
  sops = import ../../modules/sops.nix { inherit sops-nix; };
  windows = import ./windows.nix;
in
{ ... }:

{
  imports = [
    profiles.base.nixos
    profiles.system.nixos
    profiles.graphical.nixos
    gaming.nixos
    windows.nixos
    disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./secrets.nix
    ./users.nix
    (import ./home-manager.nix {
      inherit
        gaming
        profiles
        sops
        windows
        ;
    })
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos";

  system.stateVersion = "25.11";
}
