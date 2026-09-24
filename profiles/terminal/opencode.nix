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
      context = ../../files/opencode/AGENTS.md;
      agents = ../../files/opencode/agents;
    };

    programs.zsh.shellAliases.o = "OPENCODE_ENABLE_EXA=1 opencode";
  };
}
