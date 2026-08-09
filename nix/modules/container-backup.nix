{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.host.containerBackups;
in
{
  options.host.containerBackups = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            repository = lib.mkOption {
              type = lib.types.str;
              description = "restic repository path or URI";
              example = "/mnt/nas/homelab/backups/ha-restic";
            };

            paths = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "directories to back up";
            };

            services = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = ''
                systemd unit names to stop before backup and start after.
              '';
            };

            timerConfig = lib.mkOption {
              type = lib.types.attrsOf utils.systemdUtils.unitOptions.unitOption;
              default = {
                OnCalendar = "03:00";
                Persistent = true;
                RandomizedDelaySec = "10m";
              };
              description = "systemd.timer config for the backup timer";
            };

            mountPoint = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "If set, backup + restore units RequiresMountsFor this (CIFS/NFS automounts)";
            };
          };
        }
      )
    );
    default = { };
    description = "Per-set restic backup + first-provision restore for container state";
  };

  config = lib.mkIf (cfg != { }) {
    sops.secrets."restic-repo-password" = { };

    # Auto-declare one external-endpoint per backup set so the dashboard
    # tracks heartbeat failures (missed daily runs).
    services.gatus.settings.external-endpoints = lib.mkIf config.services.gatus.enable (
      lib.mapAttrsToList (name: _: {
        inherit name;
        token = "\${GATUS_EXTERNAL_TOKEN}";
        heartbeat.interval = "25h";
        alerts = [ { type = "ntfy"; } ];
      }) cfg
    );

    services.restic.backups = lib.mapAttrs (name: value: {
      inherit (value) repository paths timerConfig;
      passwordFile = config.sops.secrets."restic-repo-password".path;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
      backupPrepareCommand = lib.optionalString (value.services != [ ]) ''
        ${pkgs.systemd}/bin/systemctl stop ${lib.concatStringsSep " " value.services}
      '';
      backupCleanupCommand =
        lib.optionalString (value.services != [ ]) ''
          ${pkgs.systemd}/bin/systemctl start ${lib.concatStringsSep " " value.services}
        ''
        + lib.optionalString config.services.gatus.enable ''
          ${pkgs.curl}/bin/curl -fsS -X POST \
            -H "Authorization: Bearer $GATUS_EXTERNAL_TOKEN" \
            "http://127.0.0.1:8080/api/v1/endpoints/backups_backup-${name}/external?success=true" || true
        '';
    }) cfg;

    systemd.services = lib.mkMerge (
      lib.mapAttrsToList (
        name: value:
        let
          sentinel = "/var/lib/.${name}-provisioned";
          restoreName = "container-backup-restore-${name}";
        in
        {
          ${restoreName} = {
            description = "Restore ${name} backup (first-provision only)";
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            unitConfig = {
              ConditionPathExists = "!${sentinel}";
              RequiresMountsFor = lib.optional (value.mountPoint != null) "${value.mountPoint}";
            };
            serviceConfig = {
              Type = "oneshot";
              Restart = "on-failure";
              RestartSec = "2min";
              Environment = [
                "RESTIC_REPOSITORY=${value.repository}"
                "RESTIC_PASSWORD_FILE=${config.sops.secrets."restic-repo-password".path}"
                "RESTIC_CACHE_DIR=/var/cache/restic"
              ];
              ExecStart = pkgs.writeShellScript "restore-${name}" ''
                set -euo pipefail

                # Initialize repo if needed (no-op if already exists).
                restic init 2>/dev/null || true

                # Case 1: repo unreachable → fail hard, systemd retries in 2 min.
                count=$(restic snapshots --json | jq 'length')

                # Case 2: 0 snapshots → nothing to restore.
                [[ "$count" -eq 0 ]] && { echo "no snapshots to restore"; exit 0; }

                # Case 3: snapshots exist → restore latest.
                restic restore latest --target /
              '';
              ExecStartPost = "${pkgs.coreutils}/bin/touch ${sentinel}";
              PrivateTmp = true;
              CacheDirectory = "restic";
            };
            path = [
              pkgs.restic
              pkgs.jq
            ];
          };

          "restic-backups-${name}" = lib.mkMerge [
            (lib.optionalAttrs (value.mountPoint != null) {
              unitConfig.RequiresMountsFor = [ "${value.mountPoint}" ];
            })
            (lib.optionalAttrs config.services.gatus.enable {
              serviceConfig.EnvironmentFile = config.sops.templates."gatus-env".path;
            })
          ];
        }
        // lib.genAttrs (map (s: lib.removeSuffix ".service" s) value.services) (_: {
          after = [ "${restoreName}.service" ];
          requires = [ "${restoreName}.service" ];
        })
      ) cfg
    );
  };
}
