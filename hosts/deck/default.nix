inputs@{
  home-manager,
  plasma-manager,
  sops-nix,
  ...
}:

let
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
  localeModule = import ../../modules/locale.nix;
  nasModule = import ../../modules/nas.nix;
  nixModule = import ../../modules/nix.nix;
  plasma = import ./plasma { inherit plasma-manager; };
  profiles = import ../../profiles inputs;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
  steamRomManager = import ./steam-rom-manager.nix;
in
{
  homeManager =
    { pkgs, ... }:
    {
      imports = [
        homeManagerModule.homeManager
        nasModule.homeManager
        nixModule.homeManager
        sopsModule.homeManager
        localeModule.homeManager
        profiles.apps.homeManager
        profiles.gaming.homeManager
        profiles.terminal.homeManager
        plasma.homeManager
        steamRomManager.homeManager
      ];

      home = {
        username = "deck";
        homeDirectory = "/home/deck";
        stateVersion = "26.05";
      };

      home.sessionPath = [ "/nix/var/nix/profiles/default/bin" ];

      services.flatpak.packages = [ "com.valvesoftware.SteamLink" ];

      sops.defaultSopsFile = ../../secrets/desktop.yaml;
      my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
      my.nas.shares = [
        "Homelab"
        "Benjamin"
        "Ludusavi"
        "Ludusavi-Deck"
        "Restic"
      ];
      my.gaming.gamesPaths = [
        "/run/media/deck/976d3eeb-4b99-4f9b-b67c-a708c59432e7"
        "/home/deck/Games"
      ];
      my.gaming.ludusaviBackupPath = "/Ludusavi-Deck";
      home.packages = [ inputs.self.packages.${pkgs.system}.eden-steamdeck-pgo ];
      systemd.user.services.sdgyrodsu = {
        Unit.Description = "Cemuhook DSU server for the Steam Deck Gyroscope";
        Service = {
          ExecStart = "${inputs.jovian.legacyPackages.${pkgs.system}.sdgyrodsu}/bin/sdgyrodsu";
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
