inputs@{ ... }:

let
  profiles = import ../../profiles inputs;
  host = import ./host.nix;
  networking = import ./networking.nix;
  dnsmasq = import ./dnsmasq.nix;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi.nixos
      host.nixos
      networking.nixos
      dnsmasq.nixos
    ];
  };
}
