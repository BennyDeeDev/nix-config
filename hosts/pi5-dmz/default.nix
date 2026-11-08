inputs@{ ... }:

let
  profiles = import ../../profiles inputs;
  caddy = import ./caddy.nix;
  host = import ./host.nix;
  minecraft = import ./minecraft.nix;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi.nixos
      caddy.nixos
      host.nixos
      minecraft.nixos
    ];
  };
}
