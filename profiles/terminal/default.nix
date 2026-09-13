let
  cli = import ./cli.nix;
  git = import ./git.nix;
  nixTools = import ./nix-tools.nix;
  opencode = import ./opencode.nix;
  profile = import ./profile.nix;
  ssh = import ./ssh.nix;
in
{
  homeManager = {
    imports = [
      cli.homeManager
      git.homeManager
      nixTools.homeManager
      opencode.homeManager
      profile.homeManager
      ssh.homeManager
    ];
  };
}
