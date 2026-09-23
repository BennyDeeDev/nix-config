{
  edenPackage,
  profiles,
  sopsModule,
  windows,
}:

let
  nasModule = import ../../modules/nas.nix;
  steamRomManager = import ./steam-rom-manager.nix;
in
{
  nixos = {
    home-manager = {
      extraSpecialArgs = {
        nixConfig = "/home/benjamin/Repos/nix-config";
        flakeHost = "desktop";
      };
      users.benjamin =
        { pkgs, ... }:
        {
          imports = [
            profiles.apps.homeManager
            profiles.nixosDesktop.homeManager
            nasModule.homeManager
            profiles.kde.homeManager
            profiles.terminal.homeManager
            sopsModule.homeManager
            profiles.gaming.homeManager
            steamRomManager.homeManager
            windows.homeManager
          ];

          sops.defaultSopsFile = ../../secrets/desktop.yaml;
          my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
          my.kde.kickoffIcon = "nix-snowflake";
          my.nas.shares = [
            "Homelab"
            "Benjamin"
            "Ludusavi"
            "Restic"
          ];
          my.gaming.gamesPath = "/mnt/games";
          my.gaming.portableGamesPath = "/run/media/benjamin/976d3eeb-4b99-4f9b-b67c-a708c59432e7";
          my.gaming.ludusaviBackupPath = "/Ludusavi/ludusavi-backup";
          home.packages = [
            edenPackage
            pkgs.nixos-icons
          ];

          home = {
            username = "benjamin";
            homeDirectory = "/home/benjamin";
            stateVersion = "25.11";
          };
        };
    };
  };
}
