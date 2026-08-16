{
  homeManager =
    { pkgs, ... }:
    {
      programs.ghostty.package = pkgs.ghostty-bin;
      xdg.configFile."ghostty/config-local".source = ../../files/ghostty/macos.conf;
    };
}
