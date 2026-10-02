{
  darwin = {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "uninstall";
        upgrade = true;
      };
      greedyCasks = true;
      taps = [
        {
          name = "TheBoredTeam/boring-notch";
          trusted = true;
        }
      ];
      casks = [ "boring-notch" ];
    };
  };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        appcleaner
        caffeine
        podman
        stats
        the-unarchiver
      ];
    };
}
