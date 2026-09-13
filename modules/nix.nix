let
  nixSettings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixSystemSettings = nixSettings // {
    auto-optimise-store = true;
  };

  nixGc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  common = {
    nixpkgs.config.allowUnfree = true;
    nix.settings = nixSystemSettings;
  };
in
{
  homeManager =
    { pkgs, ... }:
    {
      nix = {
        package = pkgs.nix;
        settings = nixSettings;
        gc = nixGc;
      };
    };

  nixos = common // {
    nix = common.nix // {
      gc = nixGc;
    };
  };

  darwin = common // {
    nix = common.nix // {
      gc = {
        automatic = true;
        interval = {
          Weekday = 1;
          Hour = 0;
          Minute = 0;
        };
        options = "--delete-older-than 30d";
      };
    };
  };
}
