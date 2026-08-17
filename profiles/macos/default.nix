{ home-manager }:

let
  apps = import ./apps.nix;
  finder = import ./finder.nix;
  ghostty = import ./ghostty.nix;
  appsModule = import ../../modules/apps.nix;
  ghosttyModule = import ../../modules/ghostty.nix;
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
  input = import ./input.nix;
  nixModule = import ../../modules/nix.nix;
  profile = import ./profile.nix;
  settings = import ./settings.nix;
  vscodeModule = import ../../modules/vscode.nix;
  vscode = import ./vscode.nix;
in
{
  homeManager = {
    imports = [
      apps.homeManager
      appsModule.homeManager
      ghosttyModule.homeManager
      homeManagerModule.homeManager
      ghostty.homeManager
      vscodeModule.homeManager
      vscode.homeManager
    ];
  };

  darwin = {
    imports = [
      homeManagerModule.darwin
      apps.darwin
      finder.darwin
      input.darwin
      nixModule.darwin
      profile.darwin
      settings.darwin
    ];
  };
}
