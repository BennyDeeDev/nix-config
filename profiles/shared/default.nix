{
  dgop,
  dms,
  dms-plugin-registry,
}:

let
  apps = import ./apps.nix;
  ghostty = import ./ghostty.nix;
  vscode = import ./vscode.nix;
  profile = import ./profile.nix;
in
{
  homeManager = {
    imports = [
      apps.homeManager
      ghostty.homeManager
      profile.homeManager
      vscode.homeManager
    ];
  };
}
