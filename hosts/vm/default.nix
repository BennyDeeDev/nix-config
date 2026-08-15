{
  dgop,
  dms,
  dms-plugin-registry,
  home-manager,
  sops-nix,
  ...
}:

let
  systemProfile = import ../../profiles/system { inherit home-manager; };
  terminalProfile = import ../../profiles/terminal { };
  graphicalProfile = import ../../profiles/graphical {
    inherit dgop dms dms-plugin-registry;
  };
  audio = import ../../profiles/system/audio.nix { };
  networkmanager = import ../../profiles/system/networkmanager.nix { };
  sops = import ../../modules/sops.nix { inherit sops-nix; };
in
{
  config,
  pkgs,
  ...
}:

{
  imports = [
    systemProfile.nixos
    terminalProfile.nixos
    graphicalProfile.nixos
    audio.nixos
    networkmanager.nixos
    sops.nixos
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos-vm";

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

  services.openssh.enable = true;
  services.spice-vdagentd.enable = true;

  home-manager.users.benjamin = {
    imports = [
      terminalProfile.homeManager
      graphicalProfile.homeManager
      audio.homeManager
      networkmanager.homeManager
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
