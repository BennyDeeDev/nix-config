{
  darwin = {
    homebrew = {
      enable = true;
      onActivation.cleanup = "uninstall";
      taps = [
        {
          name = "TheBoredTeam/boring-notch";
          trusted = true;
        }
      ];
      casks = [
        "boring-notch"
        "stats"
      ];
    };
  };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        appcleaner
        caffeine
        podman
        the-unarchiver
      ];
    };
}
