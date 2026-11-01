{
  nixos =
    { config, ... }:
    {
      my.beszel.agent = {
        enable = true;
        hubUrl = "http://127.0.0.1:8090";
        tokenSopsFile = ../../secrets/pi5-server.yaml;
      };

      sops.secrets."healthchecks_uuid".sopsFile = ../../secrets/pi5-server.yaml;

      sops.templates."beszel-hub-env".content = ''
        HEARTBEAT_URL=https://hc-ping.com/${config.sops.placeholder."healthchecks_uuid"}
        HEARTBEAT_INTERVAL=60
        HEARTBEAT_METHOD=GET
      '';

      services.beszel.hub = {
        enable = true;
        environment = {
          APP_URL = "https://stats.benjaminderksen.com";
          DISABLE_SSH = "true";
        };
        environmentFile = config.sops.templates."beszel-hub-env".path;
      };

      my.restic.beszel = {
        repository = "/mnt/nas/restic/beszel-restic";
        path = "/var/lib/beszel-hub";
        service = "beszel-hub.service";
        mountPoint = "/mnt/nas/restic";
      };
    };
}
