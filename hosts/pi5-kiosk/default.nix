inputs@{
  nixos-hardware,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  sops = import ../../modules/sops.nix { inherit sops-nix; };
  pi5 = import ../../modules/pi5.nix { };
in
{ ... }:

{
  imports = [
    profiles.base.nixos
    sops.nixos
    pi5.nixos
    nixos-hardware.nixosModules.raspberry-pi-5
  ];

  networking.hostName = "pi5-kiosk";

  # TODO: kiosk display / browser config
}
