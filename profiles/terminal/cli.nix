{
  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.zsh = {
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
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
        };
        initContent = lib.mkOrder 1300 ''
          zd() {
            if (( $# == 0 )); then
              builtin cd ~
            elif [[ -d "$1" ]]; then
              builtin cd -- "$1"
            else
              z "$@" && printf '\U000F17A9 ' && pwd ||
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

      xdg.enable = true;

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
      };
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };

      programs.bat.enable = true;
      programs.btop.enable = true;
      programs.eza = {
        enable = true;
        enableZshIntegration = true;
        icons = "auto";
      };
      programs.fastfetch.enable = true;
      programs.fd.enable = true;
      programs.jq.enable = true;
      programs.ripgrep.enable = true;

      home.sessionVariables = {
        BAT_THEME = "ansi";
        BAT_PAGER = "";
        DOTFILES = "${config.home.homeDirectory}/Repos/dotfiles";
      };

      home.packages =
        (with pkgs; [
          yq-go
          xq
          tree
          tldr
          curl
          wget
          watch
          unzip
          sqlite
        ])
        ++ lib.optionals pkgs.stdenv.isLinux (
          with pkgs;
          [
            sshpass
            libsecret
          ]
        );
    };
}
