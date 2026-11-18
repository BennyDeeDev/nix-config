{
  nixos =
    { ... }:
    {
      services.immich = {
        enable = true;
        host = "127.0.0.1";
        settings.server.externalDomain = "https://photos.benjaminderksen.com";
      };

      services.postgresql.enableTCPIP = false;

      services.postgresqlBackup = {
        enable = true;
        databases = [ "immich" ];
        location = "/var/backup/postgresql";
        startAt = [ ];
      };

      my.restic.immich = {
        repository = "/mnt/nas/restic/immich-restic";
        paths = [
          "/var/lib/immich"
          "/var/backup/postgresql"
        ];
        services = [ "immich-server.service" ];
        prepareServices = [ "postgresqlBackup-immich.service" ];
        mountPoint = "/mnt/nas/restic";
      };
    };
}
