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

  home-manager.extraSpecialArgs.dotfiles = "/home/benjamin/Repos/dotfiles";

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

  services.openssh.enable = true;
  services.spice-vdagentd.enable = true;

  home-manager.users.benjamin = {
    imports = [
      profiles.system.homeManager
      profiles.terminal.homeManager
      profiles.graphical.homeManager
    ];

    home.username = "benjamin";
    home.homeDirectory = "/home/benjamin";
    home.stateVersion = "25.11";
    programs.git.settings.user = {
      name = "BennyDeeDev";
      email = "45900418+BennyDeeDev@users.noreply.github.com";
    };
  };

  system.stateVersion = "25.11";
}
