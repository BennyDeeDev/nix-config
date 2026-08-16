{ sops-nix }:

let
  locale = import ./locale.nix;
  nixModule = import ../../modules/nix.nix;
  profile = import ./profile.nix;
  programs = import ./programs.nix;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
in
{
  nixos = {
    imports = [
      locale.nixos
      nixModule.nixos
      profile.nixos
      programs.nixos
      sopsModule.nixos
    ];
  };
}
