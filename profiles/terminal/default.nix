let
  cli = import ./cli.nix;
  git = import ./git.nix;
  neovim = import ./neovim.nix;
  opencode = import ./opencode.nix;
  profile = import ./profile.nix;
  ssh = import ./ssh.nix;
in
{
  homeManager = {
    imports = [
      cli.homeManager
      git.homeManager
      neovim.homeManager
      opencode.homeManager
      profile.homeManager
      ssh.homeManager
    ];
  };
}
