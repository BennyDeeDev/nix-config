{
  homeManager = { ... }: {
    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "master";
        pull.rebase = true;
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
  };
}
