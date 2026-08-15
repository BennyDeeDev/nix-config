{ ... }:

{
  homeManager = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      inter
      fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-color-emoji
    ];

    fonts.fontconfig = lib.mkIf pkgs.stdenv.isLinux {
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
