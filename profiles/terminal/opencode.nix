{
  homeManager = { pkgs, ... }: {
    programs.opencode = {
      enable = true;
      package = pkgs.opencode;
      settings = {
        default_agent = "plan";
        autoupdate = false;
        compaction = {
          auto = true;
          prune = true;
        };
        permission = {
          read = "allow";
          edit = "allow";
          webfetch = "allow";
          websearch = "allow";
          external_directory = "allow";
          bash = "allow";
        };
      };
      tui = {
        theme = "catppuccin";
        attention = {
          enabled = true;
          notifications = false;
          sound = true;
          volume = 0.25;
        };
      };
    };

    programs.zsh.shellAliases.o = "opencode";
    programs.zsh.shellAliases.o-exa = "OPENCODE_ENABLE_EXA=1 opencode";
    programs.zsh.shellAliases.o-parallel = "OPENCODE_ENABLE_PARALLEL=1 opencode";
  };
}
