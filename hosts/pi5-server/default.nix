inputs@{
  nixos-hardware,
  ...
}:

let
  profiles = import ../../profiles inputs;
  host = import ./host.nix;
  homeAssistant = import ./home-assistant.nix;
  nas = import ../../modules/nas.nix;
  container-backup = import ../../modules/container-backup.nix;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi5.nixos
      nas.nixos
      container-backup.nixos
      nixos-hardware.nixosModules.raspberry-pi-5
      homeAssistant.nixos
      host.nixos
    ];
  };
}
