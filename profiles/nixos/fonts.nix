{
  homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        inter
        fira-code
        nerd-fonts.iosevka
        noto-fonts
        noto-fonts-color-emoji
      ];

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
          monospace = [ "Hack Nerd Font" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
