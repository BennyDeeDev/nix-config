{ home-manager }:

{
  darwin = {
    imports = [ home-manager.darwinModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
