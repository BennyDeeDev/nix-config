let
  apps = import ./apps.nix;
  ghostty = import ./ghostty.nix;
  keybindings = import ./keybindings.nix;
  vscode = import ./vscode.nix;
in
{
  homeManager = {
    imports = [
      apps.homeManager
      ghostty.homeManager
      keybindings.homeManager
      vscode.homeManager
    ];
  };
}
