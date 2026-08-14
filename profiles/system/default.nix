{ lib, ... }@args:

(import ../../lib/load-features.nix { inherit lib; }) {
  directory = ./.;
  inherit args;
}
