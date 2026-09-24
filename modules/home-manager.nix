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

  homeManager =
    {
      lib,
      pkgs,
      ...
    }:
    {
      news.display = "silent";
      targets.genericLinux.enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
      programs.home-manager.enable = true;
    };
}
