{ home-manager }:

let
  linux = import ./nixos.nix { inherit home-manager; };
  macos = import ./macos.nix { inherit home-manager; };
in
{
  inherit (linux) nixos;
  inherit (macos) darwin homeManager;
}
