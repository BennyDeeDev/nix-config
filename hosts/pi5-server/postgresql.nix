{
  nixos =
    { config, ... }:
    {
      services.postgresql = {
        enable = true;
        enableTCPIP = false;
      };

      services.postgresqlBackup = {
        enable = true;
        backupAll = true;
        location = "/var/backup/postgresql";
        # The Restic backup starts this oneshot service before taking its snapshot.
        startAt = [ ];
      };

      systemd.services.restic-backups-postgresql = {
        requires = [ "postgresqlBackup.service" ];
        after = [ "postgresqlBackup.service" ];
      };

      my.restic.postgresql = {
        repository = "/mnt/nas/restic/postgresql-restic";
        path = toString config.services.postgresqlBackup.location;
        mountPoint = "/mnt/nas/restic";
      };
    };
}
