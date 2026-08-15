{ home-manager }:

let
  linux = import ./nixos.nix { inherit home-manager; };
  darwin = import ./darwin.nix { inherit home-manager; };
in
{
  inherit (linux) nixos;
  inherit (darwin) darwin;
}
