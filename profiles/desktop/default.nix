{
  home-manager,
  lanzaboote,
  noctalia,
  noctalia-greeter,
}:

let
  apps = import ./apps.nix;
  audio = import ./audio.nix;
  bluetooth = import ./bluetooth.nix;
  boot = import ./boot.nix { inherit lanzaboote; };
  btrfs = import ./btrfs.nix;
  fonts = import ./fonts.nix;
  ghostty = import ./ghostty.nix;
  appsModule = import ../../modules/apps.nix;
  ghosttyModule = import ../../modules/ghostty.nix;
  gnomeKeyring = import ./gnome-keyring.nix;
  gnomeDisks = import ./gnome-disks.nix;
  input = import ./input.nix;
  libvirt = import ./libvirt.nix;
  nautilus = import ./nautilus.nix;
  networkmanager = import ./networkmanager.nix;
  noctaliaFeature = import ./noctalia.nix {
    inherit noctalia noctalia-greeter;
  };
  niri = import ./niri.nix;
  nixos = import ./nixos.nix;
  profile = import ./profile.nix;
  shares = import ./shares.nix;
  studioDisplay = import ./studio-display.nix;
  vscode = import ./vscode.nix;
  xdg = import ./xdg.nix;
  zsa = import ./zsa.nix;
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
  vscodeModule = import ../../modules/vscode.nix;
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
      gnomeKeyring.nixos
      gnomeDisks.nixos
      input.nixos
      libvirt.nixos
      nautilus.nixos
      networkmanager.nixos
      nixos.nixos
      noctaliaFeature.nixos
      niri.nixos
      profile.nixos
      shares.nixos
      studioDisplay.nixos
      xdg.nixos
      zsa.nixos
    ];
  };

  homeManager = {
    imports = [
      audio.homeManager
      bluetooth.homeManager
      fonts.homeManager
      apps.homeManager
      appsModule.homeManager
      ghosttyModule.homeManager
      ghostty.homeManager
      gnomeKeyring.homeManager
      input.homeManager
      nautilus.homeManager
      networkmanager.homeManager
      noctaliaFeature.homeManager
      niri.homeManager
      shares.homeManager
      studioDisplay.homeManager
      vscodeModule.homeManager
      vscode.homeManager
      xdg.homeManager
    ];
  };
}
