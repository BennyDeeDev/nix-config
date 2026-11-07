{
  nixos = {
    services.dnsmasq = {
      enable = true;
      # networkd/resolved handles the router's own upstream DNS.
      resolveLocalQueries = false;
      settings = {
        interface = [
          "enP1p3s0"
          "enP1p4s0"
          "wg0"
        ];
        except-interface = [
          "end0"
          "lo"
        ];
        bind-dynamic = true;

        no-resolv = true;
        server = [ "192.168.178.1" ];
        domain-needed = true;
        bogus-priv = true;
        domain = "home.arpa";
        local = "/home.arpa/";

        dhcp-authoritative = true;
        dhcp-range = [
          "set:dmz,10.77.20.100,10.77.20.199,255.255.255.0,12h"
          "set:trusted,10.77.10.100,10.77.10.199,255.255.255.0,12h"
        ];
        dhcp-option = [
          "tag:dmz,option:router,10.77.20.1"
          "tag:dmz,option:dns-server,10.77.20.1"
          "tag:trusted,option:router,10.77.10.1"
          "tag:trusted,option:dns-server,10.77.10.1"
        ];
        log-dhcp = true;
      };
    };
  };
}
