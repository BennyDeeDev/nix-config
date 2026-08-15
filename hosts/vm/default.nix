inputs:

let
  profiles = import ../../profiles inputs;
in
{
  config,
  pkgs,
  ...
}:

{
  imports = [
    profiles.base.nixos
    profiles.system.nixos
    profiles.graphical.nixos
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos-vm";

  home-manager = {
    extraSpecialArgs.dotfiles = "/home/benjamin/Repos/dotfiles";
    users.benjamin = {
      imports = [
        profiles.system.homeManager
        profiles.terminal.homeManager
        profiles.graphical.homeManager
      ];

      home = {
        username = "benjamin";
        homeDirectory = "/home/benjamin";
        stateVersion = "25.11";
      };
    };
  };

  sops.secrets."benjamin-password" = {
    sopsFile = ../../secrets/common.yaml;
    neededForUsers = true;
  };

  users.users.benjamin = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    hashedPasswordFile = config.sops.secrets."benjamin-password".path;
  };

  services = {
    openssh.enable = true;
    spice-vdagentd.enable = true;
  };

  system.stateVersion = "25.11";
}
