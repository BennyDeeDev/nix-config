{
  homeManager = { ... }: {
    programs.git = {
      enable = true;
      settings = {
        init = {
          defaultBranch = "master";
        };
        pull = {
          rebase = true;
        };
        user = {
          name = "BennyDeeDev";
          email = "45900418+BennyDeeDev@users.noreply.github.com";
        };
      };
    };

    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
      gitCredentialHelper.enable = false;
    };

    programs.lazygit = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh.shellAliases = {
      g = "git";
      gcm = "git commit -m";
      gcam = "git commit -a -m";
    };
  };
}
