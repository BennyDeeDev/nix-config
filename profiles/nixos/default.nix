{ sops-nix }:

let
  locale = import ./locale.nix;
  nix = import ../../modules/nix.nix;
  profile = import ./profile.nix;
  programs = import ./programs.nix;
  sops = import ../../modules/sops.nix { inherit sops-nix; };
in
{
  nixos = {
    imports = [
      locale.nixos
      nix.nixos
      profile.nixos
      programs.nixos
      sops.nixos
    ];
  };
}
