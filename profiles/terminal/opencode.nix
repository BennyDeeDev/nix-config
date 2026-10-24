{
  homeManager = { pkgs, ... }: {
    programs.opencode = {
      enable = true;
      package = pkgs.opencode;
      cli = {
        theme.name = "catppuccin";
        attention = {
          notifications = false;
          sound = true;
          volume = 0.25;
        };
      };
      settings = {
        default_agent = "plan";
        update = "disable";
        compaction = {
          auto = true;
        };
        permissions = [
          {
            action = "read";
            resource = "*";
            effect = "allow";
          }
          {
            action = "edit";
            resource = "*";
            effect = "allow";
          }
          {
            action = "webfetch";
            resource = "*";
            effect = "allow";
          }
          {
            action = "websearch";
            resource = "*";
            effect = "allow";
          }
          {
            action = "external_directory";
            resource = "*";
            effect = "allow";
          }
          {
            action = "shell";
            resource = "*";
            effect = "allow";
          }
        ];
        websearch = {
          provider = "random";
        };
      };
    };

    programs.zsh.shellAliases.o = "opencode";
  };
}
