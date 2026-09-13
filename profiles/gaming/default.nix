{ jovian, nix-flatpak }:

let
  bottles = import ./bottles.nix;
  flatpak = import ./flatpak.nix { inherit nix-flatpak; };
  lsfg = import ./lsfg.nix;
  ludusavi = import ./ludusavi.nix;
  ryujinx = import ./ryujinx.nix;
  steam = import ./steam.nix { inherit jovian; };
  steamRomManagerModule = import ../../modules/steam-rom-manager.nix;
  steamRomManager = import ./steam-rom-manager.nix;
in
{
  nixos = {
    imports = [
      flatpak.nixos
      steam.nixos
    ];
  };

  homeManager =
    { config, lib, ... }:
    {
      imports = [
        bottles.homeManager
        flatpak.homeManager
        lsfg.homeManager
        ludusavi.homeManager
        ryujinx.homeManager
        steam.homeManager
        steamRomManagerModule
        steamRomManager.homeManager
      ];

      options.my.gaming.gamesPath = lib.mkOption {
        type = lib.types.str;
        description = "Host-specific root directory for gaming data.";
      };

      config.systemd.user.tmpfiles.rules = [
        "d ${config.my.gaming.gamesPath}/PC 0755 - - -"
        "d ${config.my.gaming.gamesPath}/Switch 0755 - - -"
      ];
    };
}
