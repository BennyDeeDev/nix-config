{
  nixos =
    { ... }:
    {
      services.vaultwarden = {
        enable = true;
        config = {
          DOMAIN = "https://vault.benjaminderksen.com";
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          SIGNUPS_ALLOWED = true;
        };
      };

      my.restic.vaultwarden = {
        repository = "/mnt/nas/restic/vaultwarden-restic";
        path = "/var/lib/vaultwarden";
        service = "vaultwarden.service";
        mountPoint = "/mnt/nas/restic";
      };
    };
}
