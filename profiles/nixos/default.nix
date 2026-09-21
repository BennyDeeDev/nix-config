{ sops-nix }:

let
  localeModule = import ../../modules/locale.nix;
  nixModule = import ../../modules/nix.nix;
  profile = import ./profile.nix;
  programs = import ./programs.nix;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
in
{
  nixos = {
    imports = [
      localeModule.nixos
      nixModule.nixos
      profile.nixos
      programs.nixos
      sopsModule.nixos
    ];
  };
}
