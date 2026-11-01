{
  nixos =
    { ... }:
    {
      my.beszel.agent = {
        enable = true;
        hubUrl = "http://127.0.0.1:8090";
        tokenSopsFile = ../../secrets/pi5-server.yaml;
      };

      services.beszel.hub = {
        enable = true;
        environment = {
          APP_URL = "https://stats.benjaminderksen.com";
          DISABLE_SSH = "true";
        };
      };

      my.restic.beszel = {
        repository = "/mnt/nas/restic/beszel-restic";
        path = "/var/lib/beszel-hub";
        service = "beszel-hub.service";
        mountPoint = "/mnt/nas/restic";
      };
    };
}
