{ home-manager }:

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

    home-manager = {
      backupFileExtension = "hm-backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
in
{
  nixos = {
    imports = [
      common
      home-manager.nixosModules.home-manager
    ];
  };

  darwin = {
    imports = [
      common
      home-manager.darwinModules.home-manager
    ];
  };
}
