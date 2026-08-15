inputs@{
  nixos-hardware,
  ...
}:

let
  profiles = import ../../profiles inputs;
  nas = import ../../modules/nas.nix;
  container-backup = import ../../modules/container-backup.nix;
in
{ ... }:

{
  imports = [
    profiles.base.nixos
    profiles.pi5.nixos
    nas.nixos
    container-backup.nixos
    nixos-hardware.nixosModules.raspberry-pi-5
    ./secrets.nix
    ./home-assistant.nix
  ];

  networking.hostName = "pi5-server";

  # Trusted-LAN appliance: all listening services are intentionally exposed.
  networking.firewall.enable = false;

  my.nas = {
    shares = [
      "Homelab"
      "Restic"
    ];
  };
}
