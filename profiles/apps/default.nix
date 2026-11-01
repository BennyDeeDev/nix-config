let
  apps = import ./apps.nix;
  firefox = import ./firefox.nix;
  ghostty = import ./ghostty.nix;
  keybindings = import ./keybindings.nix;
  vscode = import ./vscode.nix;
in
{
  homeManager = {
    imports = [
      apps.homeManager
      firefox.homeManager
      ghostty.homeManager
      keybindings.homeManager
      vscode.homeManager
    ];
  };
}
