{ lanzaboote }:

let
  darwin = import ./darwin.nix;
  audio = import ./audio.nix;
  bluetooth = import ./bluetooth.nix;
  boot = import ./boot.nix { inherit lanzaboote; };
  btrfs = import ./btrfs.nix;
  libvirt = import ./libvirt.nix;
  networkmanager = import ./networkmanager.nix;
  nixos = import ./nixos.nix;
  podman = import ./podman.nix;
  printing = import ./printing.nix;
  security = import ./security.nix;
in
{
  nixos = {
      imports = [
        audio.nixos
        bluetooth.nixos
        boot.nixos
        btrfs.nixos
        libvirt.nixos
        networkmanager.nixos
        nixos.nixos
        podman.nixos
        printing.nixos
        security.nixos
      ];
    };

  darwin = {
    imports = [
      darwin.darwin
      security.darwin
    ];
  };

  homeManager = {
    imports = [
      audio.homeManager
      bluetooth.homeManager
      networkmanager.homeManager
      podman.homeManager
    ];
  };
}
