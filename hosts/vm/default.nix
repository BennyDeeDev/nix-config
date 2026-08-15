{
  dgop,
  dms,
  dms-plugin-registry,
  home-manager,
  lanzaboote,
  sops-nix,
  ...
}:

let
  baseProfile = import ../../profiles/base { inherit home-manager; };
  systemProfile = import ../../profiles/system { inherit lanzaboote; };
  terminalProfile = import ../../profiles/terminal { };
  graphicalProfile = import ../../profiles/graphical {
    inherit dgop dms dms-plugin-registry;
  };
  sops = import ../../modules/sops.nix { inherit sops-nix; };
in
{
  config,
  pkgs,
  ...
}:

{
  imports = [
    baseProfile.nixos
    systemProfile.nixos
    graphicalProfile.nixos
    sops.nixos
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos-vm";

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
      systemProfile.homeManager
      terminalProfile.homeManager
      graphicalProfile.homeManager
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
