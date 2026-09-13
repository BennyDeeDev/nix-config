{
  homeManager =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      };

      xdg.configFile = {
        "ghostty/config".source = ../../files/ghostty/config;
        "ghostty/themes/catppuccin-mocha.conf".source = ../../files/ghostty/themes/catppuccin-mocha.conf;
        "ghostty/themes/catppuccin-latte.conf".source = ../../files/ghostty/themes/catppuccin-latte.conf;
        "ghostty/config-local".source =
          if pkgs.stdenv.hostPlatform.isDarwin then
            ../../files/ghostty/macos.conf
          else
            ../../files/ghostty/linux.conf;
      };

      xdg.terminal-exec = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        settings.default = [ "com.mitchellh.ghostty.desktop" ];
      };
    };
}
