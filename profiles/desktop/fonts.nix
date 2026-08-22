{
  homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
      ];

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [ "Noto Sans" ];
          serif = [ "Noto Serif" ];
          monospace = [ "Hack Nerd Font Mono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
