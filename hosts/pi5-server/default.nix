inputs@{ ... }:

let
  profiles = import ../../profiles inputs;
  host = import ./host.nix;
  blocky = import ./blocky.nix;
  caddy = import ./caddy.nix;
  homeAssistant = import ./home-assistant.nix;
  openthreadBorderRouter = import ./openthread-border-router.nix;
  matterjsServer = import ./matterjs-server.nix;
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
      homeAssistant.nixos
      openthreadBorderRouter.nixos
      matterjsServer.nixos
      host.nixos
    ];
  };
}
