{
  config,
  moduleSet,
  pkgs,
  systemProfile,
  workstationProfile,
  ...
}:

{
  imports = [
    systemProfile.nixos
    moduleSet.sops.nixos
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "nixos-vm";
    networkmanager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
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

  programs.hyprland.enable = true;
  services.openssh.enable = true;
  services.spice-vdagentd.enable = true;

  home-manager.users.benjamin = {
    imports = [ workstationProfile.homeManager ];
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
