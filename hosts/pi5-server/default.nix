inputs@{ ... }:

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
      homeAssistant.nixos
      host.nixos
    ];
  };
}
