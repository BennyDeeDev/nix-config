inputs@{
  disko,
  jovian,
  nix-flatpak,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  gaming = import ./gaming { inherit jovian nix-flatpak; };
  hardware = import ./hardware.nix;
  host = import ./host.nix;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
  secrets = import ./secrets.nix;
  users = import ./users.nix;
  windows = import ./windows.nix;
  homeManagerConfig = import ./home-manager.nix {
    inherit
      gaming
      profiles
      sopsModule
      windows
      ;
  };
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.desktop.nixos
      gaming.nixos
      windows.nixos
      disko.nixosModules.disko
      ./disko.nix
      ./hardware-configuration.nix
      hardware.nixos
      host.nixos
      secrets.nixos
      users.nixos
      homeManagerConfig.nixos
    ];
  };
}
