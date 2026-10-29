{
  nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.restic;
      resticPasswordFile = config.sops.secrets."restic-repo-password".path;
      systemctlExe = lib.getExe' config.systemd.package "systemctl";
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      mkResticBackup =
        _: value:
        {
          inherit (value) repository;
          paths = [ value.path ];
          initialize = true;
          passwordFile = resticPasswordFile;
          inherit pruneOpts timerConfig;
        }
        // lib.optionalAttrs (value.service != null) {
          backupPrepareCommand = "${systemctlExe} stop ${value.service}";
          backupCleanupCommand = "${systemctlExe} start ${value.service}";
        };
      mkResticBackupService = name: value: {
        "restic-backups-${name}" = lib.optionalAttrs (value.mountPoint != null) {
          unitConfig.RequiresMountsFor = [ "${value.mountPoint}" ];
        };
      };
    in
    {
      options.my.restic = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              repository = lib.mkOption {
                type = lib.types.str;
                description = "restic repository path or URI";
                example = "/mnt/nas/homelab/backups/ha-restic";
              };

              path = lib.mkOption {
                type = lib.types.str;
                description = "directory to back up";
              };

              service = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Optional systemd unit to stop before and start after backup.";
              };

              mountPoint = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
                description = "If set, the backup unit RequiresMountsFor this mount point";
              };
            };
          }
        );
        default = { };
        description = "Per-set Restic backup definitions";
      };

      config = lib.mkIf (cfg != { }) {
        sops.secrets."restic-repo-password" = { };

        services.restic.backups = lib.mapAttrs mkResticBackup cfg;

        systemd.services = lib.mkMerge (lib.mapAttrsToList mkResticBackupService cfg);
      };
    };
}
