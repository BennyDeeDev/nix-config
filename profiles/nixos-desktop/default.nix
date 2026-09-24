{
  home-manager,
  lanzaboote,
}:

let
  apps = import ./apps.nix;
  audio = import ./audio.nix;
  bluetooth = import ./bluetooth.nix;
  boot = import ./boot.nix { inherit lanzaboote; };
  btrfs = import ./btrfs.nix;
  libvirt = import ./libvirt.nix;
  profile = import ./profile.nix;
  studioDisplay = import ./studio-display.nix;
  zsa = import ./zsa.nix;
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
in
{
  nixos = {
    imports = [
      homeManagerModule.nixos
      apps.nixos
      audio.nixos
      bluetooth.nixos
      boot.nixos
      btrfs.nixos
      libvirt.nixos
      profile.nixos
      studioDisplay.nixos
      zsa.nixos
    ];
  };

  homeManager = {
    imports = [ studioDisplay.homeManager ];
  };
}
