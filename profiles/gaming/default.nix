{
  jovian,
  nix-flatpak,
  self,
}:

let
  bottles = import ./bottles.nix;
  flatpak = import ./flatpak.nix { inherit nix-flatpak; };
  lsfg = import ./lsfg.nix { inherit self; };
  ludusavi = import ./ludusavi.nix;
  steam = import ./steam.nix { inherit jovian; };
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
        steam.homeManager
        steamRomManager.homeManager
      ];

      options.my.gaming.gamesPaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Host-specific root directories for gaming data.";
      };

      options.my.gaming.ludusaviBackupPath = lib.mkOption {
        type = lib.types.str;
        description = "Remote path for Ludusavi backups.";
      };

      config.systemd.user.tmpfiles.rules = lib.concatMap (
        gamesPath:
        map (subdirectory: "d ${gamesPath}/${subdirectory} 0755 - - -") [
          "PC"
          "Switch"
          "Switch/30fps"
          "Switch/60fps"
        ]
      ) config.my.gaming.gamesPaths;
    };
}
