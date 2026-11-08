inputs@{ ... }:

let
  profiles = import ../../profiles inputs;
  host = import ./host.nix;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi.nixos
      host.nixos
    ];
  };
}
