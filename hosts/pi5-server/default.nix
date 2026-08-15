{
  home-manager,
  nixos-hardware,
  sops-nix,
  ...
}:

let
  baseProfile = import ../../profiles/base { inherit home-manager; };
  sops = import ../../modules/sops.nix { inherit sops-nix; };
  pi5 = import ../../modules/pi5.nix { };
  nas = import ../../modules/nas.nix { };
  container-backup = import ../../modules/container-backup.nix { };
in
{ ... }:

{
  imports = [
    baseProfile.nixos
    sops.nixos
    pi5.nixos
    nas.nixos
    container-backup.nixos
    nixos-hardware.nixosModules.raspberry-pi-5
    ./home-assistant.nix
  ];

  networking.hostName = "pi5-server";

  # Firewall disabled temporarily
  networking.firewall.enable = false;

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  host.nas = {
    shares = [
      "Homelab"
      "Restic"
    ];
  };

  sops.defaultSopsFile = ../../secrets/pi5-server.yaml;
}
