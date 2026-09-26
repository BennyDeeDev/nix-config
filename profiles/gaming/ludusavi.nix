{
  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      home = config.home.homeDirectory;
      portableGamesPath = config.my.gaming.portableGamesPath;
      backupPath = "${home}/Backups/ludusavi";
      portableBottlePath = "${portableGamesPath}/Bottles/gaming-portable-bottle";
      hostBottlePath = "${home}/.var/app/com.usebottles.bottles/data/bottles/bottles/gaming-bottle";

      mkBottleManifest = name: path: ''
        "${name}":
          files:
            "${path}/drive_c":
              tags: [save, config]
              when: [{ os: linux }]
            "${path}/bottle.yml":
              tags: [config]
              when: [{ os: linux }]
            "${path}/system.reg":
              tags: [config]
              when: [{ os: linux }]
            "${path}/user.reg":
              tags: [config]
              when: [{ os: linux }]
            "${path}/userdef.reg":
              tags: [config]
              when: [{ os: linux }]
      '';

      mkEdenManifest = path: ''
        "Eden":
          files:
            "${path}":
              tags: [save, config]
              when: [{ os: linux }]
      '';

      gamingManifest = builtins.toFile "ludusavi-gaming-manifest.yml" ''
        ${mkEdenManifest "${portableGamesPath}/Eden/nand"}
        ${mkBottleManifest "Bottles (Portable)" portableBottlePath}
        ${mkBottleManifest "Bottles (Host)" hostBottlePath}
      '';
    in
    {
      systemd.user.tmpfiles.rules = [
        "d ${backupPath} 0755 - - -"
      ];

      services.ludusavi = {
        enable = true;
        frequency = "*:0/60";
        settings = {
          manifest.secondary = [ { path = gamingManifest; } ];
          roots = [
            {
              store = "steam";
              path = "${home}/.local/share/Steam";
            }
          ];
          backup = {
            path = backupPath;
            retention.full = 24;
            format = {
              chosen = "zip";
            };
          };
          restore.path = backupPath;
          cloud = {
            remote.Smb = {
              id = "nas";
              host = "192.168.178.254";
              port = 445;
              username = "benjamin";
            };
            path = config.my.gaming.ludusaviBackupPath;
            synchronize = false;
          };
          apps.rclone.path = lib.getExe pkgs.rclone;
        };
      };

      systemd.user.services.ludusavi.Service.ExecStartPost =
        "-${lib.getExe pkgs.ludusavi} cloud upload --force";
    };
}
