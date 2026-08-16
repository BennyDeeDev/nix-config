let
  apps = import ./apps.nix;
  finder = import ./finder.nix;
  ghostty = import ./ghostty.nix;
  input = import ./input.nix;
  profile = import ./profile.nix;
  settings = import ./settings.nix;
  vscode = import ./vscode.nix;
in
{
  homeManager = {
    imports = [
      apps.homeManager
      ghostty.homeManager
      vscode.homeManager
    ];
  };

  darwin = {
    imports = [
      apps.darwin
      finder.darwin
      input.darwin
      profile.darwin
      settings.darwin
    ];
  };
}
