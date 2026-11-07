inputs@{ ... }:

let
  cage = import ./cage.nix;
  beszel = import ./beszel.nix;
  beszelAgentModule = import ../../modules/beszel-agent.nix;
  host = import ./host.nix;
  profiles = import ../../profiles inputs;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi.nixos
      beszelAgentModule.nixos
      cage.nixos
      beszel.nixos
      host.nixos
    ];
  };
}
