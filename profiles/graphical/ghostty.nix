{ ... }:

{
  homeManager = { pkgs, lib, ... }: {
    programs.ghostty = {
      enable = true;
      package = if pkgs.stdenv.isLinux then pkgs.ghostty else null;
      enableZshIntegration = true;
    };

    xdg.terminal-exec = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      settings.default = [ "com.mitchellh.ghostty.desktop" ];
    };

    xdg.configFile = {
      "ghostty/config".source = ../../files/ghostty/config;
      "ghostty/config-local".source =
        if pkgs.stdenv.isLinux then ../../files/ghostty/linux.conf else ../../files/ghostty/macos.conf;
      "ghostty/themes/catppuccin-mocha.conf".source = ../../files/ghostty/themes/catppuccin-mocha.conf;
      "ghostty/themes/catppuccin-latte.conf".source = ../../files/ghostty/themes/catppuccin-latte.conf;
    };
  };
}
