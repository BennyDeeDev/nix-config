{ config, lib, ... }:

{
  options.host.gatus.endpoints = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [ ];
    description = "Gatus endpoints observed by this host (use 127.0.0.1 for self, peer's .fritz.box for peers, never self SSH).";
  };

  config = {
    services.gatus = {
      enable = true;
      environmentFile = config.sops.templates."gatus-env".path;
      settings = {
        storage = {
          type = "sqlite";
          path = "/var/lib/gatus/data.db";
        };

        web.port = 8080;

        endpoints = config.host.gatus.endpoints;

        alerting.ntfy = {
          url = "http://127.0.0.1:8060";
          topic = "\${NTFY_TOPIC}";
          token = "\${NTFY_TOKEN}";
          default-alert = {
            failure-threshold = 3;
            success-threshold = 2;
            send-on-resolved = true;
          };
        };
      };
    };

    sops.secrets."monitoring/ntfy-topic" = { };
    sops.secrets."monitoring/ntfy-token" = { };
    sops.secrets."monitoring/gatus-external-token" = { };

    sops.templates."gatus-env" = {
      content = ''
        NTFY_TOPIC=${config.sops.placeholder."monitoring/ntfy-topic"}
        NTFY_TOKEN=${config.sops.placeholder."monitoring/ntfy-token"}
        GATUS_EXTERNAL_TOKEN=${config.sops.placeholder."monitoring/gatus-external-token"}
      '';
      owner = "gatus";
      group = "gatus";
    };
  };
}
