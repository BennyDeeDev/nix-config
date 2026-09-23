let
  apps = import ./apps.nix;
  ghostty = import ./ghostty.nix;
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
}
