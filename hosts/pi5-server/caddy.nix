{
  nixos =
    { config, ... }:
    {
      security.acme.acceptTerms = true;

      sops.secrets."cloudflare-api-token" = { };
      sops.secrets."caddy-basic-auth-hash" = { };

      sops.templates."caddy-env".content = ''
        CADDY_BASIC_AUTH_HASH=${config.sops.placeholder."caddy-basic-auth-hash"}
      '';

      security.acme.certs."benjaminderksen.com" = {
        domain = "*.benjaminderksen.com";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare-api-token".path;
      };

      services.caddy = {
        enable = true;
        openFirewall = true;
        environmentFile = config.sops.templates."caddy-env".path;

        virtualHosts."ha.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            reverse_proxy 127.0.0.1:8123
          '';
        };

        virtualHosts."immich.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            reverse_proxy 127.0.0.1:2283 {
              header_up X-Real-IP {remote_host}
            }
          '';
        };

        virtualHosts."vault.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            reverse_proxy 127.0.0.1:8222 {
              header_up X-Real-IP {remote_host}
            }
          '';
        };

        virtualHosts."status.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            reverse_proxy 127.0.0.1:8080
          '';
        };

        virtualHosts."ntfy.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            reverse_proxy 127.0.0.1:8060
          '';
        };

        virtualHosts."otbr.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            basic_auth {
              admin {$CADDY_BASIC_AUTH_HASH}
            }

            handle /api/* {
              reverse_proxy 127.0.0.1:8081
            }

            handle {
              reverse_proxy 127.0.0.1:8082
            }
          '';
        };

        virtualHosts."matter.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            basic_auth {
              admin {$CADDY_BASIC_AUTH_HASH}
            }

            reverse_proxy 127.0.0.1:5580
          '';
        };
      };
    };
}
