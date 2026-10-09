let
  profile = import ./profile.nix;
in
{
  nixos = {
    imports = [ profile.nixos ];
  };
}
