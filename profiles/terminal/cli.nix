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
            drs = ''osascript -e 'tell application "Terminal" to do script "sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ${nixConfig}#${flakeHost}"'';
            ".." = "cd ..";
            "..." = "cd ../..";
            "...." = "cd ../../..";
          };
          initContent = ''
            zd() {
              if (( $# == 0 )); then
                builtin cd ~
              elif [[ -d "$1" ]]; then
                builtin cd -- "$1"
              else
                z "$@" && printf '\\U000F17A9 ' && pwd ||
                  print -u2 "Error: Directory not found"
              fi
            }

            alias cd=zd

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
        };
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
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
