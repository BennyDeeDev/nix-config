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
in
{ ... }:

{
  imports = [
    baseProfile.nixos
    sops.nixos
    pi5.nixos
    nixos-hardware.nixosModules.raspberry-pi-5
  ];

  networking.hostName = "pi5-kiosk";

  # TODO: kiosk display / browser config
}
