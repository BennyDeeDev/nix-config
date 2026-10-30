{
  nixos =
    {
      config,
      ...
    }:
    {
      sops.secrets = {
        "ntfy-topic" = { };
        "gatus-external-token" = { };
      };

      sops.templates."gatus-env" = {
        content = ''
          NTFY_TOPIC=${config.sops.placeholder."ntfy-topic"}
          GATUS_EXTERNAL_TOKEN=${config.sops.placeholder."gatus-external-token"}
        '';
      };

      services.gatus = {
        enable = true;
        environmentFile = config.sops.templates."gatus-env".path;
        settings = {
          storage = {
            type = "sqlite";
            path = "/var/lib/gatus/data.db";
          };

          web = {
            address = "127.0.0.1";
            port = 8080;
          };

          alerting.ntfy = {
            url = "http://127.0.0.1:8060";
            topic = "\${NTFY_TOPIC}";
            default-alert = {
              failure-threshold = 3;
              success-threshold = 2;
              send-on-resolved = true;
            };
          };

          endpoints = [
            {
              name = "Home Assistant";
              group = "Applications";
              url = "https://ha.benjaminderksen.com";
              client.dns-resolver = "tcp://127.0.0.1:53";
              interval = "60s";
              conditions = [
                "[STATUS] == 200"
                "[CERTIFICATE_EXPIRATION] > 168h"
              ];
              alerts = [ { type = "ntfy"; } ];
            }
            {
              name = "Immich";
              group = "Applications";
              url = "https://immich.benjaminderksen.com";
              client.dns-resolver = "tcp://127.0.0.1:53";
              interval = "60s";
              conditions = [
                "[STATUS] == 200"
                "[CERTIFICATE_EXPIRATION] > 168h"
              ];
              alerts = [ { type = "ntfy"; } ];
            }
            {
              name = "Vaultwarden";
              group = "Applications";
              url = "https://vault.benjaminderksen.com";
              client.dns-resolver = "tcp://127.0.0.1:53";
              interval = "60s";
              conditions = [
                "[STATUS] == 200"
                "[CERTIFICATE_EXPIRATION] > 168h"
              ];
              alerts = [ { type = "ntfy"; } ];
            }
            {
              name = "OTBR";
              group = "Internal services";
              url = "http://127.0.0.1:8081/node";
              interval = "60s";
              conditions = [ "[STATUS] == 200" ];
              alerts = [ { type = "ntfy"; } ];
            }
            {
              name = "Matter";
              group = "Internal services";
              url = "tcp://127.0.0.1:5580";
              interval = "60s";
              conditions = [ "[CONNECTED] == true" ];
              alerts = [ { type = "ntfy"; } ];
            }
            {
              name = "NAS";
              group = "Storage";
              url = "tcp://192.168.178.254:445";
              interval = "60s";
              conditions = [ "[CONNECTED] == true" ];
              alerts = [ { type = "ntfy"; } ];
            }
            {
              name = "ntfy";
              group = "Applications";
              url = "https://ntfy.benjaminderksen.com/v1/health";
              client.dns-resolver = "tcp://127.0.0.1:53";
              interval = "60s";
              conditions = [
                "[STATUS] == 200"
                "[CERTIFICATE_EXPIRATION] > 168h"
              ];
              alerts = [ { type = "ntfy"; } ];
            }
            {
              name = "Gatus";
              group = "Applications";
              url = "https://status.benjaminderksen.com";
              client.dns-resolver = "tcp://127.0.0.1:53";
              interval = "60s";
              conditions = [
                "[STATUS] == 200"
                "[CERTIFICATE_EXPIRATION] > 168h"
              ];
              alerts = [ { type = "ntfy"; } ];
            }
            {
              name = "Blocky";
              group = "Internal services";
              url = "127.0.0.1";
              interval = "60s";
              dns = {
                query-name = "example.com";
                query-type = "A";
              };
              conditions = [
                "[BODY] == pat(*.*.*.*)"
                "[DNS_RCODE] == NOERROR"
              ];
              alerts = [ { type = "ntfy"; } ];
            }
          ];
        };
      };
    };
}
