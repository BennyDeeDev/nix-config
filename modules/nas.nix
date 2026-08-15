{
  nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.host.nas;
    in
    {
      options.host.nas = {
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

      config = lib.mkIf (cfg.shares != [ ]) {
        boot.supportedFilesystems = [ "cifs" ];
        environment.systemPackages = [ pkgs.cifs-utils ];

        sops.secrets."smb-username" = { };
        sops.secrets."smb-password" = { };
        sops.templates."smb-creds" = {
          content = ''
            username=${config.sops.placeholder."smb-username"}
            password=${config.sops.placeholder."smb-password"}
            domain=${cfg.domain}
          '';
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
}
