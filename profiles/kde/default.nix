{ plasma-manager }:

let
  localeModule = import ../../modules/locale.nix;
  panels = import ./panels.nix;
  profile = import ./profile.nix;
  regional = import ./regional.nix;
  shortcuts = import ./shortcuts.nix;
in
{
  nixos = {
    imports = [ profile.nixos ];
  };

  homeManager = {
    imports = [
      localeModule.homeManager
      plasma-manager.homeModules.plasma-manager
      panels.homeManager
      profile.homeManager
      regional.homeManager
      shortcuts.homeManager
    ];
  };
}
