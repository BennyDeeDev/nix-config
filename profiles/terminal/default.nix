{ ... }:

let
  cli = import ./cli.nix { };
  git = import ./git.nix { };
  helix = import ./helix.nix { };
  neovim = import ./neovim.nix { };
  opencode = import ./opencode.nix { };
in
{
  nixos =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;
      nix.settings.auto-optimise-store = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      programs.fuse.enable = true;
      programs.vim.defaultEditor = true;
      zramSwap.enable = true;
      services.envfs.enable = true;
      programs.nix-ld.enable = true;

      environment.systemPackages = [ pkgs.gcc ];
      security.sudo.extraConfig = ''
        Defaults timestamp_type=tty,timestamp_timeout=-1
      '';
    };

  homeManager = {
    imports = [
      cli.homeManager
      git.homeManager
      helix.homeManager
      neovim.homeManager
      opencode.homeManager
    ];

    programs.home-manager.enable = true;
  };
}
