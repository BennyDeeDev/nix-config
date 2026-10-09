{ cosmic-manager }:

let
  profile = import ./profile.nix;
  cosmicManagerModule = cosmic-manager.homeManagerModules.cosmic-manager;
in
{
  nixos = {
    imports = [ profile.nixos ];
  };

  homeManager = {
    imports = [
      cosmicManagerModule
      profile.homeManager
    ];
  };
}
