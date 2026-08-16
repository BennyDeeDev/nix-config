{
  homeManager =
    { pkgs, ... }:
    {
      programs.ghostty.package = pkgs.ghostty;

      xdg.terminal-exec = {
        enable = true;
        settings.default = [ "com.mitchellh.ghostty.desktop" ];
      };

      xdg.configFile."ghostty/config-local".source = ../../files/ghostty/linux.conf;
    };
}
