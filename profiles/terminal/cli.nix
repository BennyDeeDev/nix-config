{
  homeManager =
    {
      config,
      nixConfig,
      flakeHost,
      lib,
      pkgs,
      ...
    }:
    {
      xdg.enable = true;

      programs = {
        zsh = {
          enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
          autocd = true;
          history = {
            size = 50000;
            save = 50000;
            share = true;
            ignoreDups = true;
            ignoreSpace = true;
          };
          shellAliases = {
            ls = "eza -lh --group-directories-first --icons=auto";
            lsa = "ls -a";
            lt = "eza --tree --level=2 --long --icons --git";
            lta = "lt -a";
            cat = "bat";
            ff = "fzf --preview 'bat --style=numbers --color=always {}'";
            nrs = "sudo nixos-rebuild switch --flake ${nixConfig}#${flakeHost}";
            drs = "sudo darwin-rebuild switch --flake ${nixConfig}#${flakeHost}";
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
          };
          initContent = ''
            autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
            zle -N up-line-or-beginning-search
            zle -N down-line-or-beginning-search
            bindkey '^[[A' up-line-or-beginning-search
            bindkey '^[OA' up-line-or-beginning-search
            bindkey '^[[B' down-line-or-beginning-search
            bindkey '^[OB' down-line-or-beginning-search

            bindkey '^[[1;5C' forward-word
            bindkey '^[[1;5D' backward-word
            bindkey '^[[H' beginning-of-line
            bindkey '^[[F' end-of-line
            bindkey '^[[3~' delete-char
          '';
        };
        starship = {
          enable = true;
          enableZshIntegration = true;
        };
        fzf = {
          enable = true;
          enableZshIntegration = true;
        };
        zoxide = {
          enable = true;
          enableZshIntegration = true;
          options = [
            "--cmd"
            "cd"
          ];
        };
        bat = {
          enable = true;
          config = {
            theme = "ansi";
            paging = "never";
          };
        };
        btop.enable = true;
        eza = {
          enable = true;
          enableZshIntegration = true;
          icons = "auto";
        };
        fastfetch.enable = true;
        fd.enable = true;
        jq.enable = true;
        ripgrep.enable = true;
      };

      home.packages = (
        with pkgs;
        [
          yq-go
          xq
          tree
          tldr
          curl
          wget
          watch
          unzip
          sqlite
          sshpass
        ]
      );
    };
}
