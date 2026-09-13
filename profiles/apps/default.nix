let
  apps = import ./apps.nix;
  brave = import ./brave.nix;
  ghostty = import ./ghostty.nix;
  vscode = import ./vscode.nix;
in
{
  homeManager = {
    imports = [
      apps.homeManager
      brave.homeManager
      ghostty.homeManager
      vscode.homeManager
    ];
  };
}
