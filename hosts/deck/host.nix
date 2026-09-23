{ inputs }:

{
  homeManager =
    { pkgs, ... }:
    {
      home = {
        username = "deck";
        homeDirectory = "/home/deck";
        stateVersion = "26.05";
      };

      home.sessionPath = [ "/nix/var/nix/profiles/default/bin" ];

      services.flatpak.packages = [ "com.valvesoftware.SteamLink" ];

      sops.defaultSopsFile = ../../secrets/desktop.yaml;
      my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
      my.kde.kickoffIcon = "distributor-logo-steamdeck";
      my.nas.shares = [
        "Homelab"
        "Benjamin"
        "Ludusavi-Deck"
      ];
      my.gaming.gamesPath = "/home/deck/Games";
      my.gaming.portableGamesPath = "/run/media/deck/976d3eeb-4b99-4f9b-b67c-a708c59432e7";
      my.gaming.ludusaviBackupPath = "/Ludusavi-Deck";
      home.packages = [ inputs.self.packages.${pkgs.system}.eden-steamdeck-pgo ];
    };
}
