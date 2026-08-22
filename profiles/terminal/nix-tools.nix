{
  homeManager =
    { pkgs, ... }:
    {
      programs = {
        television.enable = true;
        nix-search-tv = {
          enable = true;
          enableTelevisionIntegration = true;
        };
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };
      };

      home.packages = [
        pkgs.dix
        pkgs.nix-diff
      ];
    };
}
