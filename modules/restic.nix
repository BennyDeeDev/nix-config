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
        OnCalendar = "*-*-* 04:00:00";
        Persistent = true;
      };
      mkResticBackup =
        _: value:
        {
          inherit (value) repository paths;
          initialize = true;
          passwordFile = resticPasswordFile;
          inherit pruneOpts timerConfig;
        }
        // lib.optionalAttrs (value.services != [ ] || value.prepareServices != [ ]) {
          backupPrepareCommand = ''
            set -e
            ${lib.optionalString (value.services != [ ]) ''
              ${systemctlExe} stop ${lib.escapeShellArgs value.services}
            ''}
            ${lib.optionalString (value.prepareServices != [ ]) ''
              ${systemctlExe} start ${lib.escapeShellArgs value.prepareServices}
            ''}
          '';
        }
        // lib.optionalAttrs (value.services != [ ]) {
          backupCleanupCommand = "${systemctlExe} start ${lib.escapeShellArgs value.services}";
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

              paths = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Directories to back up.";
              };

              services = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Systemd units to stop before and start after backup.";
              };

              prepareServices = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Oneshot units to run after stopping services and before backup.";
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
