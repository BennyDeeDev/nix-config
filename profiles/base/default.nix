{
  home-manager,
  sops-nix,
}:

let
  gc = import ./gc.nix;
  locale = import ./locale.nix;
  nix = import ./nix.nix { inherit home-manager; };
  programs = import ./programs.nix;
  sops = import ./sops.nix { inherit sops-nix; };
  zram = import ./zram.nix;
in
{
  nixos = {
    imports = [
      gc.nixos
      locale.nixos
      nix.nixos
      programs.nixos
      sops.nixos
      zram.nixos
    ];
  };

  darwin = {
    imports = [
      gc.darwin
      nix.darwin
    ];
  };
}
