inputs@{ ... }:

let
  profiles = import ../../profiles inputs;
  host = import ./host.nix;
  networking = import ./networking.nix;
  dnsmasq = import ./dnsmasq.nix;
  firewall = import ./firewall.nix;
  wireguard = import ./wireguard.nix;
  wgAccessServer = import ./wg-access-server.nix;
  ntopng = import ./ntopng.nix;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi.nixos
      host.nixos
      networking.nixos
      dnsmasq.nixos
      firewall.nixos
      wireguard.nixos
      wgAccessServer.nixos
      ntopng.nixos
    ];
  };
}
