inputs@{
  home-manager,
  plasma-manager,
  sops-nix,
  ...
}:

let
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
  nixModule = import ../../modules/nix.nix;
  plasma = import ./plasma { inherit plasma-manager; };
  profiles = import ../../profiles inputs;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
in
{
  homeManager =
    { ... }:
    {
      imports = [
        homeManagerModule.homeManager
        nixModule.homeManager
        sopsModule.homeManager
        profiles.apps.homeManager
        profiles.gaming.homeManager
        profiles.terminal.homeManager
        plasma.homeManager
      ];

      home = {
        username = "deck";
        homeDirectory = "/home/deck";
        stateVersion = "26.05";
      };

      sops.defaultSopsFile = ../../secrets/desktop.yaml;
      my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
      my.gaming.gamesPath = "/run/media/mmcblk0p1";
    };
}
