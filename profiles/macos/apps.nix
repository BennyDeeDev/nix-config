{
  darwin = {
    homebrew = {
      enable = true;
      onActivation = {
        # Avoid nix-homebrew losing the mas PATH during auto-update re-exec.
        # https://github.com/zhaofengli/nix-homebrew/issues/131
        autoUpdate = false;
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
