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
  nasModule = import ../../modules/nas.nix;
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
    edenPackage = inputs.self.packages.x86_64-linux.eden-rog-ally-pgo;
  };
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.nixosDesktop.nixos
      nasModule.nixos
      profiles.kde.nixos
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
