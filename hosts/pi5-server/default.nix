inputs@{ ... }:

let
  profiles = import ../../profiles inputs;
  host = import ./host.nix;
  blocky = import ./blocky.nix;
  caddy = import ./caddy.nix;
  gatus = import ./gatus.nix;
  homeAssistant = import ./home-assistant.nix;
  immich = import ./immich.nix;
  otbr = import ./otbr.nix;
  matter = import ./matter.nix;
  postgresql = import ./postgresql.nix;
  ntfy = import ./ntfy.nix;
  vaultwarden = import ./vaultwarden.nix;
  nasModule = import ../../modules/nas.nix;
  resticModule = import ../../modules/restic.nix;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi5.nixos
      nasModule.nixos
      resticModule.nixos
      blocky.nixos
      caddy.nixos
      gatus.nixos
      homeAssistant.nixos
      immich.nixos
      otbr.nixos
      matter.nixos
      postgresql.nixos
      ntfy.nixos
      vaultwarden.nixos
      host.nixos
    ];
  };
}
