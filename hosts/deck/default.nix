inputs@{
  home-manager,
  plasma-manager,
  sops-nix,
  ...
}:

let
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
  nasModule = import ../../modules/nas.nix;
  nixModule = import ../../modules/nix.nix;
  plasma = import ./plasma { inherit plasma-manager; };
  profiles = import ../../profiles inputs;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
  steamRomManager = import ./steam-rom-manager.nix;
in
{
  homeManager =
    { lib, ... }:
    {
      imports = [
        homeManagerModule.homeManager
        nasModule.homeManager
        nixModule.homeManager
        sopsModule.homeManager
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

      sops.defaultSopsFile = ../../secrets/desktop.yaml;
      my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
      my.nas.shares = [
        "Homelab"
        "Benjamin"
        "Ludusavi"
        "Restic"
      ];
      my.gaming.gamesPath = "/run/media/mmcblk0p1";
      systemd.user.timers.ludusavi.Install.WantedBy = lib.mkForce [ ];
    };
}
