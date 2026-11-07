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
  beszel = import ./beszel.nix;
  beszelAgentModule = import ../../modules/beszel-agent.nix;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi.nixos
      beszelAgentModule.nixos
      host.nixos
      networking.nixos
      dnsmasq.nixos
      firewall.nixos
      wireguard.nixos
      wgAccessServer.nixos
      ntopng.nixos
      beszel.nixos
    ];
  };
}
