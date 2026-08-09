{ config, ... }:

{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "http://${config.networking.hostName}.fritz.box:8060";
      listen-http = ":8060";
      cache-file = "/var/lib/ntfy-sh/cache.db";
    };
  };
}