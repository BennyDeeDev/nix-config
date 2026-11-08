{
  nixos =
    { config, ... }:
    {
      sops.secrets."wg-access-server" = {
        sopsFile = ../../secrets/pi5-router.yaml;
        # A YAML document stored as a block string in the host's SOPS file.
        restartUnits = [ "wg-access-server.service" ];
      };

      services.wg-access-server = {
        enable = true;
        secretsFile = config.sops.secrets."wg-access-server".path;
        settings = {
          adminUsername = "admin";
          externalHost = "192.168.178.2";
          storage = "sqlite3:///var/lib/wg-access-server/db.sqlite";
          wireguard = {
            interface = "wg1";
            port = 51821;
          };
          vpn = {
            cidr = "10.77.40.0/24";
            cidrv6 = "0";
            allowedIPs = [ "0.0.0.0/0" ];
            gatewayInterface = "end0";
            disableIPTables = true;
          };
          dns.enabled = false;
          clientConfig.dnsServers = [ "10.77.40.1" ];
          https = {
            enabled = true;
            port = 8443;
          };
        };
      };
    };
}
