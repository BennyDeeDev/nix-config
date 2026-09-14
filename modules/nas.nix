let
  nasOptions = lib: {
    server = lib.mkOption {
      type = lib.types.str;
      default = "192.168.178.254";
    };
    shares = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    uid = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
    };
    gid = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "WORKGROUP";
    };
  };
in
{
  nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.my.nas;
    in
    {
      options.my.nas = nasOptions lib;

      config = lib.mkIf (cfg.shares != [ ]) {
        boot.supportedFilesystems = [ "cifs" ];
        environment.systemPackages = [ pkgs.cifs-utils ];

        sops = {
          secrets."smb-username" = { };
          secrets."smb-password" = { };
          templates."smb-creds" = {
            content = ''
              username=${config.sops.placeholder."smb-username"}
              password=${config.sops.placeholder."smb-password"}
              domain=${cfg.domain}
            '';
          };
        };

        fileSystems = builtins.listToAttrs (
          map (
            share:
            lib.nameValuePair "/mnt/nas/${lib.toLower share}" {
              fsType = "cifs";
              device = "//${cfg.server}/${share}";
              # noauto + x-systemd.automount: don't mount at boot, lazily attach on first access
              options = [
                "noauto,x-systemd.automount"
                "credentials=${config.sops.templates."smb-creds".path}"
              ]
              ++ lib.optional (
                cfg.uid != null && cfg.gid != null
              ) "uid=${toString cfg.uid},gid=${toString cfg.gid}";
            }
          ) cfg.shares
        );
      };
    };

  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.nas;
      remote = "nas";
      mountRoot = "${config.home.homeDirectory}/mnt/nas";
      lower = share: lib.toLower share;
      mountPath = share: "${mountRoot}/${lower share}";
      cachePath = share: "${config.xdg.cacheHome}/rclone/${lower share}";
      serviceName = share: "rclone-nas-${lower share}";
      fusermount = lib.getExe' pkgs.fuse3 "fusermount3";
    in
    {
      options.my.nas = nasOptions lib;

      config = {
        programs.rclone.enable = true;

        sops = {
          secrets."smb-username" = { };
          secrets."smb-password-rclone-obscured" = { };
          templates."rclone.conf" = {
            content = ''
              [${remote}]
              type = smb
              host = ${cfg.server}
              port = 445
              user = ${config.sops.placeholder."smb-username"}
              pass = ${config.sops.placeholder."smb-password-rclone-obscured"}
            '';
            path = "${config.xdg.configHome}/rclone/rclone.conf";
          };
        };

        systemd.user.tmpfiles.rules = map (share: "d ${mountPath share} 0755 - - -") cfg.shares;

        systemd.user.services = lib.listToAttrs (
          map (
            share:
            lib.nameValuePair (serviceName share) {
              Unit = {
                Description = "Mount NAS ${share} with rclone";
                After = [
                  "network-online.target"
                  "sops-nix.service"
                ];
                Wants = [
                  "network-online.target"
                  "sops-nix.service"
                ];
              };
              Service = {
                Type = "notify";
                ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p ${mountPath share}";
                ExecStart = lib.concatStringsSep " " [
                  (lib.getExe pkgs.rclone)
                  "mount"
                  "${remote}:${share}"
                  (mountPath share)
                  "--config=${config.xdg.configHome}/rclone/rclone.conf"
                  "--cache-dir=${cachePath share}"
                  "--vfs-cache-mode=writes"
                  "--umask=022"
                ];
                ExecStop = "-${fusermount} -uz ${mountPath share}";
                Restart = "on-failure";
                RestartSec = "10s";
              };
              Install.WantedBy = [ "default.target" ];
            }
          ) cfg.shares
        );
      };
    };
}
