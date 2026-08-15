inputs@{
  nixos-hardware,
  ...
}:

let
  profiles = import ../../profiles inputs;
in
{ ... }:

{
  imports = [
    profiles.base.nixos
    profiles.pi5.nixos
    nixos-hardware.nixosModules.raspberry-pi-5
  ];

  networking.hostName = "pi5-kiosk";

  # TODO: kiosk display / browser config
}
