{
  homeManager.programs.helix = {
    enable = true;

    settings.theme = "catppuccin_mocha";

    languages.language = [
      {
        # https://github.com/helix-editor/helix/issues/10803
        name = "nix";
        formatter.command = "nixfmt";
        auto-format = true;
      }
    ];

    # Use adaptive themes when the nixpkgs Helix version supports them:
    # settings.theme = {
    #   light = "catppuccin_latte";
    #   dark = "catppuccin_mocha";
    # };
  };
}
