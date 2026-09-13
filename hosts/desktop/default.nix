inputs@{
  disko,
  jovian,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  hardware = import ./hardware.nix;
  host = import ./host.nix;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
  secrets = import ./secrets.nix;
  users = import ./users.nix;
  windows = import ./windows.nix;
  homeManagerConfig = import ./home-manager.nix {
    inherit
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
      profiles.gaming.nixos
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
