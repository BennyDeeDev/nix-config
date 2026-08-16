let
  common = {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
in
{
  nixos = common // {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  darwin = common // {
    nix.gc = {
      automatic = true;
      interval = {
        Weekday = 1;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };
}
