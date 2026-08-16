{
  dgop,
  dms,
  dms-plugin-registry,
}:

let
  apps = import ./apps.nix;
  ghostty = import ./ghostty.nix;
  vscode = import ./vscode.nix;
  homeManager = import ./home-manager.nix;
in
{
  homeManager = {
    imports = [
      apps.homeManager
      ghostty.homeManager
      vscode.homeManager
      homeManager.homeManager
    ];
  };
}
