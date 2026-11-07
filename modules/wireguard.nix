{
  nixos =
    { config, ... }:
    {
      networking.wireguard = {
        enable = true;
        interfaces.wg0 = {
          privateKeyFile = config.sops.secrets."wireguard-private-key".path;
          peers = [
            {
              publicKey = "<ROUTER_PUBLIC_KEY>";
              endpoint = "192.168.178.2:51820";
              allowedIPs = [
                "10.77.10.0/24"
                "10.77.20.0/24"
                "10.77.30.0/24"
              ];
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
}
