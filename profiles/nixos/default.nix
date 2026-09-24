{ sops-nix }:

let
  localeModule = import ../../modules/locale.nix;
  nixModule = import ../../modules/nix.nix;
  input = import ./input.nix;
  profile = import ./profile.nix;
  programs = import ./programs.nix;
  runtime = import ./runtime.nix;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
in
{
  nixos = {
    imports = [
      input.nixos
      localeModule.nixos
      nixModule.nixos
      profile.nixos
      programs.nixos
      runtime.nixos
      sopsModule.nixos
    ];
  };
}
