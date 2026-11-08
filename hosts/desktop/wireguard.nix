{
  nixos =
    { config, ... }:
    {
      sops.secrets."wireguard-private-key" = {
        sopsFile = ../../secrets/desktop.yaml;
        restartUnits = [ "NetworkManager-ensure-profiles.service" ];
      };

      sops.templates."wireguard-networkmanager.env".content = ''
        WG_PRIVATE_KEY=${config.sops.placeholder."wireguard-private-key"}
      '';

      networking = {
        # IPv6 routing and leak prevention are deferred.
        enableIPv6 = false;
        networkmanager = {
          ensureProfiles = {
            environmentFiles = [ config.sops.templates."wireguard-networkmanager.env".path ];

            profiles.wg0 = {
              connection = {
                id = "wg0";
                type = "wireguard";
                interface-name = "wg0";
                autoconnect = "false";
              };

              wireguard = {
                private-key = "$WG_PRIVATE_KEY";
                peer-routes = "true";
                ip4-auto-default-route = "true";
                mtu = "1420";
              };

              "wireguard-peer.dpN4F877R/xVBoGw3gEM/jeg0B8f+XbMRHcnilm1/mg=" = {
                endpoint = "192.168.178.2:51820";
                allowed-ips = "0.0.0.0/0;";
                persistent-keepalive = "25";
              };

              ipv4 = {
                method = "manual";
                address1 = "10.77.30.2/32";
                dns = "10.77.30.1;";
                dns-priority = "-50";
              };
            };
          };
        };
      };
    };
}
