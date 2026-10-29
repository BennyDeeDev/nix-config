{
  nixos =
    { config, ... }:
    {
      security.acme.acceptTerms = true;

      sops.secrets."cloudflare-api-token" = { };

      security.acme.certs."benjaminderksen.com" = {
        domain = "*.benjaminderksen.com";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        credentialFiles."CF_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare-api-token".path;
      };

      services.caddy = {
        enable = true;
        openFirewall = true;

        virtualHosts."ha.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            reverse_proxy 127.0.0.1:8123
          '';
        };

        virtualHosts."vault.benjaminderksen.com" = {
          useACMEHost = "benjaminderksen.com";
          extraConfig = ''
            reverse_proxy 127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT} {
              header_up X-Real-IP {remote_host}
            }
          '';
        };
      };
    };
}
