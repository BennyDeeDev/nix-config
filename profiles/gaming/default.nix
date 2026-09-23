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
in
{
  nixos = {
    imports = [
      flatpak.nixos
      steam.nixos
    ];
  };

  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        bottles.homeManager
        flatpak.homeManager
        lsfg.homeManager
        ludusavi.homeManager
        steam.homeManager
      ];

      config.home.packages = with pkgs; [
        steam-rom-manager
        stremio-linux-shell
        vacuum-tube
      ];

      options.my.gaming.gamesPath = lib.mkOption {
        type = lib.types.str;
        description = "Host-specific local root directory for gaming data.";
      };

      options.my.gaming.portableGamesPath = lib.mkOption {
        type = lib.types.str;
        description = "Host-specific removable root directory for gaming data.";
      };

      options.my.gaming.ludusaviBackupPath = lib.mkOption {
        type = lib.types.str;
        description = "Remote path for Ludusavi backups.";
      };

      config.systemd.user.tmpfiles.rules = [
        "d ${config.my.gaming.gamesPath}/PC 0755 - - -"
        "d ${config.my.gaming.gamesPath}/Switch 0755 - - -"
        "d ${config.my.gaming.gamesPath}/Switch/30fps 0755 - - -"
        "d ${config.my.gaming.gamesPath}/Switch/60fps 0755 - - -"
      ];
    };
}
