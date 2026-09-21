{
  edenPackage,
  profiles,
  sopsModule,
  windows,
}:

let
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
            profiles.desktop.homeManager
            profiles.terminal.homeManager
            sopsModule.homeManager
            profiles.gaming.homeManager
            steamRomManager.homeManager
            windows.homeManager
          ];

          sops.defaultSopsFile = ../../secrets/desktop.yaml;
          my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
          my.gaming.gamesPaths = [ "/mnt/games" ];
          my.gaming.ludusaviBackupPath = "/Ludusavi/ludusavi-backup";
          home.packages = [ edenPackage ];

          home = {
            username = "benjamin";
            homeDirectory = "/home/benjamin";
            stateVersion = "25.11";
          };
        };
    };
  };
}
