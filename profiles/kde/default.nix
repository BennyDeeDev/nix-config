{ plasma-manager }:

let
  localeModule = import ../../modules/locale.nix;
  lookAndFeel = import ./look-and-feel.nix;
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
      lookAndFeel.homeManager
      panels.homeManager
      profile.homeManager
      regional.homeManager
      shortcuts.homeManager
    ];
  };
}
