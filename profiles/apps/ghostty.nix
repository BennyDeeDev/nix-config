{
  homeManager =
    {
      lib,
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
              keybind = [
                "ctrl+c=copy_to_clipboard"
                "ctrl+v=paste_from_clipboard"
                "ctrl+t=new_tab"
                "ctrl+w=close_surface"
                "ctrl+one=goto_tab:1"
                "ctrl+two=goto_tab:2"
                "ctrl+three=goto_tab:3"
                "ctrl+four=goto_tab:4"
                "ctrl+five=goto_tab:5"
                "ctrl+six=goto_tab:6"
                "ctrl+seven=goto_tab:7"
                "ctrl+eight=goto_tab:8"
                "ctrl+nine=goto_tab:9"
                "super+shift+2=text:\\x00"
                "super+a=text:\\x01"
                "super+b=text:\\x02"
                "super+c=text:\\x03"
                "super+d=text:\\x04"
                "super+e=text:\\x05"
                "super+f=text:\\x06"
                "super+g=text:\\x07"
                "super+h=text:\\x08"
                "super+i=text:\\x09"
                "super+j=text:\\x0a"
                "super+k=text:\\x0b"
                "super+l=text:\\x0c"
                "super+m=text:\\x0d"
                "super+n=text:\\x0e"
                "super+o=text:\\x0f"
                "super+p=text:\\x10"
                "super+q=text:\\x11"
                "super+r=text:\\x12"
                "super+s=text:\\x13"
                "super+t=text:\\x14"
                "super+u=text:\\x15"
                "super+v=text:\\x16"
                "super+w=text:\\x17"
                "super+x=text:\\x18"
                "super+y=text:\\x19"
                "super+z=text:\\x1a"
                "super+bracket_left=text:\\x1b"
                "super+backslash=text:\\x1c"
                "super+bracket_right=text:\\x1d"
                "super+shift+6=text:\\x1e"
                "super+slash=text:\\x1f"
              ];
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
