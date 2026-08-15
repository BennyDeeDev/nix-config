inputs@{
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  sops = import ../../modules/sops.nix { inherit sops-nix; };
in
{ ... }:

{
  imports = [
    profiles.base.darwin
    profiles.system.darwin
    profiles.graphical.darwin
    ./users.nix
    (import ./home-manager.nix { inherit profiles sops; })
    ./homebrew.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.stateVersion = 5;
}
