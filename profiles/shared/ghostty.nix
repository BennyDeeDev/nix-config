{
  homeManager =
    { ... }:
    {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
      };

      xdg.configFile = {
        "ghostty/config".source = ../../files/ghostty/config;
        "ghostty/themes/catppuccin-mocha.conf".source = ../../files/ghostty/themes/catppuccin-mocha.conf;
        "ghostty/themes/catppuccin-latte.conf".source = ../../files/ghostty/themes/catppuccin-latte.conf;
      };
    };
}
