{
  nixos =
    { lib, ... }:
    {
      # Disable before public exposure; trusted-interface SSH stays open.
      services.openssh.openFirewall = true;

      networking = {
        nftables.enable = true;
        firewall = {
          enable = true;
          filterForward = true;
          checkReversePath = "strict";

          interfaces = {
            end0.allowedUDPPorts = [ 68 ];
            enP1p3s0 = {
              allowedTCPPorts = [ 53 ];
              allowedUDPPorts = [
                53
                67
              ];
            };
            enP1p4s0 = {
              allowedTCPPorts = [
                22
                53
              ];
              allowedUDPPorts = [
                53
                67
              ];
            };
          };

          # Must precede NAT's WAN allowance to block private upstream access.
          extraForwardRules = lib.mkBefore ''
            iifname "enP1p3s0" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } counter drop comment "DMZ cannot reach private networks"
          '';
        };
      };
    };
}
