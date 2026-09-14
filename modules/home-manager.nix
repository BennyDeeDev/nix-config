{ home-manager }:

let
  common = {
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

  homeManager = {
    news.display = "silent";
    targets.genericLinux.enable = true;
    programs.home-manager.enable = true;
  };
}
