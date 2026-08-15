{ lanzaboote }:

let
  linux = import ./nixos.nix { };
  darwin = import ./darwin.nix { };
  audio = import ./audio.nix { };
  bluetooth = import ./bluetooth.nix { };
  boot = import ./boot.nix { inherit lanzaboote; };
  libvirt = import ./libvirt.nix { };
  networkmanager = import ./networkmanager.nix { };
  podman = import ./podman.nix { };
  printing = import ./printing.nix { };
in
{
  nixos = {
    imports = [
      linux.nixos
      audio.nixos
      bluetooth.nixos
      boot.nixos
      libvirt.nixos
      networkmanager.nixos
      podman.nixos
      printing.nixos
    ];
  };

  inherit (darwin) darwin;

  homeManager = {
    imports = [
      darwin.homeManager
      audio.homeManager
      bluetooth.homeManager
      networkmanager.homeManager
      podman.homeManager
    ];
  };
}
