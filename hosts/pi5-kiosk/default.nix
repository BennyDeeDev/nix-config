inputs@{ ... }:

let
  cage = import ./cage.nix;
  host = import ./host.nix;
  profiles = import ../../profiles inputs;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi5.nixos
      cage.nixos
      host.nixos
    ];
  };
}
