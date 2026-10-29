{
  nixos = {
    services.blocky = {
      enable = true;
      enableConfigCheck = true;
      settings = {
        ports.dns = "0.0.0.0:53";

        upstreams.groups.default = [ "https://dns.quad9.net/dns-query" ];

        bootstrapDns = [
          {
            upstream = "https://dns.quad9.net/dns-query";
            ips = [
              "9.9.9.9"
              "149.112.112.112"
            ];
          }
        ];

        conditional.mapping = {
          "fritz.box" = "192.168.178.1";
          "178.168.192.in-addr.arpa" = "192.168.178.1";
        };

        customDNS.mapping = {
          "ha.benjaminderksen.com" = "192.168.178.52";
          "immich.benjaminderksen.com" = "192.168.178.52";
          "vault.benjaminderksen.com" = "192.168.178.52";
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

    networking.firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
