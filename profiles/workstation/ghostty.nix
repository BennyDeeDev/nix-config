{ repoRoot, ... }:

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
      "ghostty/config".source = repoRoot + "/files/ghostty/config";
      "ghostty/config-local".source =
        if pkgs.stdenv.isLinux then
          repoRoot + "/files/ghostty/linux.conf"
        else
          repoRoot + "/files/ghostty/macos.conf";
      "ghostty/themes/catppuccin-mocha.conf".source =
        repoRoot + "/files/ghostty/themes/catppuccin-mocha.conf";
      "ghostty/themes/catppuccin-latte.conf".source =
        repoRoot + "/files/ghostty/themes/catppuccin-latte.conf";
    };
  };
}
