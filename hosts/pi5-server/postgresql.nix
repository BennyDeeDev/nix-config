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
        # Run before the existing Restic timer, which fires daily at midnight.
        startAt = "*-*-* 23:00:00";
      };

      my.restic.postgresql = {
        repository = "/mnt/nas/restic/postgresql-restic";
        path = toString config.services.postgresqlBackup.location;
        mountPoint = "/mnt/nas/restic";
      };
    };
}
