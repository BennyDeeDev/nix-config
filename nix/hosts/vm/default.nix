{ workstationProfile, ... }:

{
  imports = [
    ../../system/base.nix
    ../../system/desktop.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos-vm";

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
}
