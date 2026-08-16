let
  cli = import ./cli.nix;
  git = import ./git.nix;
  helix = import ./helix.nix;
  neovim = import ./neovim.nix;
  opencode = import ./opencode.nix;
in
{
  homeManager = {
    imports = [
      cli.homeManager
      git.homeManager
      helix.homeManager
      neovim.homeManager
      opencode.homeManager
    ];
  };
}
