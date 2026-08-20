{
  homeManager =
    { config, lib, ... }:
    let
      personalIdentity = {
        name = "BennyDeeDev";
        email = "45900418+BennyDeeDev@users.noreply.github.com";
      };
      personalRepositoryInclude = repository: {
        condition = "gitdir:${repository}";
        contents = {
          user = personalIdentity;
          commit.gpgSign = false;
          tag.gpgSign = false;
        };
      };
    in
    {
      options.my.git = {
        identity = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = personalIdentity;
        };

        personalRepositories = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };
      };

      config = {
        programs.git = {
          enable = true;
          settings = {
            init.defaultBranch = "master";
            pull.rebase = true;
            user = config.my.git.identity;
          };
          includes = map personalRepositoryInclude config.my.git.personalRepositories;
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
    };
}
