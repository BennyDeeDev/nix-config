{
  home-manager,
  sops-nix,
}:

let
  gc = import ./gc.nix;
  locale = import ./locale.nix;
  nix = import ./nix.nix { inherit home-manager; };
  profile = import ./profile.nix;
  programs = import ./programs.nix;
  sops = import ./sops.nix { inherit sops-nix; };
in
{
  nixos = {
    imports = [
      gc.nixos
      locale.nixos
      nix.nixos
      profile.nixos
      programs.nixos
      sops.nixos
    ];
  };

  darwin = {
    imports = [
      gc.darwin
      nix.darwin
    ];
  };
}
