{
  nixos =
    { lib, ... }:
    {
      # Temporarily opens SSH on TCP 22 on every interface, including WAN/DMZ.
      # Disable before public exposure; trusted-interface SSH stays explicit.
      services.openssh.openFirewall = true;

      networking = {
        nftables.enable = true;
        firewall = {
          enable = true;
          filterForward = true;
          checkReversePath = "strict";
          # VPN peers are trusted for all services running on the router.
          trustedInterfaces = [
            "wg0"
            "wg1"
          ];

          interfaces = {
            end0.allowedUDPPorts = [
              68 # DHCPv4 client replies from the upstream network
              51820 # WireGuard peer handshakes
              51821 # wg-access-server peer handshakes
            ];
            enP1p3s0 = {
              allowedTCPPorts = [ 53 ]; # DNS over TCP
              allowedUDPPorts = [
                53 # DNS over UDP
                67 # DHCPv4 server requests from DMZ clients
              ];
            };
            enP1p4s0 = {
              allowedTCPPorts = [
                22 # SSH administration from the trusted network
                53 # DNS over TCP
                8443 # wg-access-server HTTPS UI
              ];
              allowedUDPPorts = [
                53 # DNS over UDP
                67 # DHCPv4 server requests from trusted clients
              ];
            };
          };

          # Must precede NAT's WAN allowance to block private upstream access.
          extraForwardRules = lib.mkBefore ''
            iifname "enP1p3s0" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } counter drop comment "DMZ cannot reach private networks"
            iifname { "wg0", "wg1" } accept comment "WireGuard peers may route to all networks"
          '';
        };
      };
    };
}
