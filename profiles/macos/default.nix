{ home-manager }:

let
  apps = import ./apps.nix;
  finder = import ./finder.nix;
  hammerspoon = import ./hammerspoon.nix;
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
  input = import ./input.nix;
  nixModule = import ../../modules/nix.nix;
  profile = import ./profile.nix;
  settings = import ./settings.nix;
  users = import ./users.nix;
in
{
  homeManager = {
    imports = [
      apps.homeManager
      hammerspoon.homeManager
      homeManagerModule.homeManager
    ];
  };

  darwin = {
    imports = [
      homeManagerModule.darwin
      apps.darwin
      finder.darwin
      hammerspoon.darwin
      input.darwin
      nixModule.darwin
      profile.darwin
      settings.darwin
      users
    ];
  };
}
