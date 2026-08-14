{ ... }:

{
  darwin = ../../nix/system/darwin.nix;
  homeManager = {
    imports = [ ../../nix/home/sops.nix ];
  };
}
