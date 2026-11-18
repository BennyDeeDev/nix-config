let
  serverAddresses = "192.168.178.10,fd22:f689:1dae::2ecf:67ff:fe26:7db";
in
{
  nixos = {
    services.blocky = {
      enable = true;
      enableConfigCheck = true;
      settings = {
        # A wildcard without an IP listens on both IPv4 and IPv6.
        ports.dns = ":53";

        upstreams.groups.default = [ "https://dns.quad9.net/dns-query" ];

        bootstrapDns = [
          {
            upstream = "https://dns.quad9.net/dns-query";
            ips = [
              "9.9.9.9"
              "149.112.112.112"
              "2620:fe::fe"
              "2620:fe::9"
            ];
          }
        ];

        conditional.mapping = {
          "fritz.box" = "192.168.178.1";
          "178.168.192.in-addr.arpa" = "192.168.178.1";
        };

        customDNS.mapping = {
          "docs.benjaminderksen.com" = serverAddresses;
          "ha.benjaminderksen.com" = serverAddresses;
          "matter.benjaminderksen.com" = serverAddresses;
          "ntfy.benjaminderksen.com" = serverAddresses;
          "otbr.benjaminderksen.com" = serverAddresses;
          "photos.benjaminderksen.com" = serverAddresses;
          "stats.benjaminderksen.com" = serverAddresses;
          "status.benjaminderksen.com" = serverAddresses;
          "vault.benjaminderksen.com" = serverAddresses;
        };

        blocking = {
          denylists.ads = [
            "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
          ];
          clientGroupsBlock.default = [ "ads" ];
        };

        caching = {
          maxTime = "30m";
          prefetching = true;
        };
      };
    };

    # Upstream wants network-online.target but does not order Blocky after it,
    # so denylist loading can race DHCP at boot. Remove once upstream adds it.
    systemd.services.blocky.after = [ "network-online.target" ];

    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
