{
  homeManager =
    {
      pkgs,
      ...
    }:
    let
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
    in
    {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        package = if isLinux then pkgs.ghostty else pkgs.ghostty-bin;
        settings = {
          "font-family" = "Hack Nerd Font Mono";
          "font-style" = "Regular";
          "shell-integration" = "zsh";
          "window-padding-x" = 8;
          "window-padding-y" = 8;
          "quit-after-last-window-closed" = true;
          "confirm-close-surface" = false;
          "adjust-cursor-thickness" = 2;
          theme = "dark:Catppuccin Mocha,light:Catppuccin Latte";
        }
        // (
          if isLinux then
            {
              "font-size" = 14;
              maximize = false;
            }
          else
            {
              "font-size" = 16;
              "macos-titlebar-style" = "tabs";
              "background-opacity" = 0.85;
              "background-blur" = 0;
            }
        );
      };
    };
}
