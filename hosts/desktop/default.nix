inputs@{
  disko,
  nix-flatpak,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  gaming = import ./gaming { inherit nix-flatpak; };
  hardware = import ./hardware.nix;
  host = import ./host.nix;
  sops = import ../../modules/sops.nix { inherit sops-nix; };
  secrets = import ./secrets.nix;
  users = import ./users.nix;
  windows = import ./windows.nix;
  homeManager = import ./home-manager.nix {
    inherit
      gaming
      profiles
      sops
      windows
      ;
  };
in
{
  nixos = {
    imports = [
      profiles.base.nixos
      profiles.nixos.nixos
      gaming.nixos
      windows.nixos
      disko.nixosModules.disko
      ./disko.nix
      ./hardware-configuration.nix
      hardware.nixos
      host.nixos
      secrets.nixos
      users.nixos
      homeManager.nixos
    ];
  };
}
