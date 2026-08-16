{ home-manager }:

{
  nixos = {
    imports = [ home-manager.nixosModules.home-manager ];

    home-manager = {
      backupFileExtension = "hm-backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  darwin = {
    imports = [ home-manager.darwinModules.home-manager ];

    home-manager = {
      backupFileExtension = "hm-backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
