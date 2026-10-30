{
  nixos =
    { ... }:
    {
      services.ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.benjaminderksen.com";
          listen-http = "127.0.0.1:8060";
          cache-file = "/var/lib/ntfy-sh/cache.db";
          auth-default-access = "read-write";
          behind-proxy = true;
          upstream-base-url = "https://ntfy.sh";
        };
      };
    };
}
