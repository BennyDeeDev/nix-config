{
  nixos =
    { config, ... }:
    {
      sops.secrets."wireguard-private-key" = {
        sopsFile = ../../secrets/pi5-router.yaml;
        restartUnits = [ "systemd-networkd.service" ];
      };

      networking = {
        wireguard = {
          enable = true;
          useNetworkd = true;
          interfaces.wg0 = {
            ips = [ "10.77.30.1/24" ];
            listenPort = 51820;
            privateKeyFile = config.sops.secrets."wireguard-private-key".path;
            peers = [
              {
                publicKey = "<DESKTOP_PUBLIC_KEY>";
                allowedIPs = [ "10.77.30.2/32" ];
              }
            ];
          };
        };
      };
    };
}
