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
    in
    {
      systemd.user.tmpfiles.rules = [
        "d ${backupPath} 0755 - - -"
      ];

      services.ludusavi = {
        enable = true;
        frequency = "*:0/15";
        settings = {
          manifest.secondary = [
            {
              path = "${builtins.toFile "ludusavi-eden-manifest.yml" ''
                "Eden":
                  files:
                    "${portableGamesPath}/Eden/nand":
                      tags: [save]
                      when: [{ os: linux }]
              ''}";
            }
          ];
          roots = [
            {
              store = "steam";
              path = "${home}/.local/share/Steam";
            }
            {
              store = "otherWine";
              path = "${portableGamesPath}/Bottles/gaming-portable-bottle";
            }
          ];
          backup = {
            path = backupPath;
            retention.full = 50;
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
        "${lib.getExe pkgs.ludusavi} cloud upload --force";
    };
}
