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
      mountPath = share: "/mnt/nas/${lib.toLower share}";
      mkFileSystemEntry =
        share:
        lib.nameValuePair (mountPath share) {
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
        };
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

        fileSystems = lib.genAttrs' cfg.shares mkFileSystemEntry;
      };
    };

  homeManagerExclusive =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.nas;
      mountPath = share: "${config.home.homeDirectory}/mnt/nas/${lib.toLower share}";
      mkMount = share: {
        enable = true;
        mountPoint = mountPath share;
        options = {
          vfs-cache-mode = "writes";
        };
      };
    in
    {
      options.my.nas = nasOptions lib;

      config = lib.mkIf (cfg.shares != [ ]) {
        programs.rclone = {
          enable = true;

          remotes.nas = {
            config = {
              type = "smb";
              host = cfg.server;
            };

            secrets = {
              user = config.sops.secrets."smb-username".path;
              pass = config.sops.secrets."smb-password".path;
            };

            mounts = lib.genAttrs cfg.shares mkMount;
          };
        };

        sops.secrets = {
          "smb-username" = { };
          "smb-password" = { };
        };
      };
    };
}
