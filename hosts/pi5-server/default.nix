inputs@{
  nixos-hardware,
  ...
}:

let
  profiles = import ../../profiles inputs;
  host = import ./host.nix;
  homeAssistant = import ./home-assistant.nix;
  nasModule = import ../../modules/nas.nix;
  containerBackupModule = import ../../modules/container-backup.nix;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi5.nixos
      nasModule.nixos
      containerBackupModule.nixos
      nixos-hardware.nixosModules.raspberry-pi-5
      homeAssistant.nixos
      host.nixos
    ];
  };
}
