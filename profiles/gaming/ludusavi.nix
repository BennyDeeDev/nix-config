{
  homeManager =
    {
      config,
      ...
    }:
    let
      home = config.home.homeDirectory;
    in
    {
      systemd.user.tmpfiles.rules = [
        "d ${home}/Backups/ludusavi 0755 - - -"
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
                    "${config.my.gaming.portableGamesPath}/Eden/nand":
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
              path = "${config.my.gaming.portableGamesPath}/Bottles/gaming-portable-bottle";
            }
          ];
          backup = {
            path = "${home}/Backups/ludusavi";
            retention.full = 50;
            format = {
              chosen = "zip";
            };
          };
          restore.path = "${home}/Backups/ludusavi";
          cloud = {
            remote.Smb = {
              id = "nas";
              host = "192.168.178.254";
              port = 445;
              username = "benjamin";
            };
            path = config.my.gaming.ludusaviBackupPath;
            synchronize = true;
          };
          apps.rclone.path = "rclone";
        };
      };
    };
}
