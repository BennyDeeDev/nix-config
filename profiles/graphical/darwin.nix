{
  darwin = {
    homebrew = {
      taps = [
        {
          name = "TheBoredTeam/boring-notch";
          trusted = true;
        }
      ];
      casks = [
        "boring-notch"
        "ghostty"
        "stats"
      ];
    };
  };

  homeManager =
    { lib, pkgs, ... }:
    {
      home.packages = lib.optionals pkgs.stdenv.isDarwin (
        with pkgs;
        [
          appcleaner
          caffeine
          the-unarchiver
        ]
      );
    };
}
