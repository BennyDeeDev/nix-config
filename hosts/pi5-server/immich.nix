{
  nixos =
    { ... }:
    {
      services.immich = {
        enable = true;
        host = "127.0.0.1";
        settings.server.externalDomain = "https://immich.benjaminderksen.com";
      };

      my.restic.immich = {
        repository = "/mnt/nas/restic/immich-restic";
        path = "/var/lib/immich";
        service = "immich-server.service";
        mountPoint = "/mnt/nas/restic";
      };
    };
}
