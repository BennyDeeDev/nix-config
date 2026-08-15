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
        initContent = ''
          # File system
          if command -v eza &> /dev/null; then
            alias ls='eza -lh --group-directories-first --icons=auto'
            alias lsa='ls -a'
            alias lt='eza --tree --level=2 --long --icons --git'
            alias lta='lt -a'
          fi

          if command -v bat &> /dev/null; then
            alias cat='bat'
          fi

          alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

          if command -v zoxide &> /dev/null; then
            alias cd="zd"
            zd() {
              if [ $# -eq 0 ]; then
                builtin cd ~ && return
              elif [ -d "$1" ]; then
                builtin cd "$1"
              else
                z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
              fi
            }
          fi

          # Directories
          alias ..='cd ..'
          alias ...='cd ../..'
          alias ....='cd ../../..'

          autoload -U up-line-or-beginning-search
          autoload -U down-line-or-beginning-search
          zle -N up-line-or-beginning-search
          zle -N down-line-or-beginning-search
          bindkey "^[[A" up-line-or-beginning-search
          bindkey "^[OA" up-line-or-beginning-search
          bindkey "^[[B" down-line-or-beginning-search
          bindkey "^[OB" down-line-or-beginning-search

          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word

          bindkey "^[[H" beginning-of-line
          bindkey "^[[F" end-of-line

          bindkey "^[[3~" delete-char

          [[ $TERM != "linux" ]] && eval "$(starship init zsh)"
        '';
      };

      xdg.enable = true;

      programs.starship = {
        enable = true;
        enableZshIntegration = false;
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
      programs.eza.enable = true;
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
