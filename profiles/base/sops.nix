{ sops-nix }:

{
  nixos = {
    imports = [ (import ../../modules/sops.nix { inherit sops-nix; }).nixos ];
  };
}
