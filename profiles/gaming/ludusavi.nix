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
      services.ludusavi = {
        enable = true;
        frequency = "*-*-* 03:00:00";
        settings = {
          manifest.secondary = [
            {
              url = "https://raw.githubusercontent.com/BennyDeeDev/ludusavi-emudeck-manifest-flatpak/main/manifest.yml";
            }
          ];
          roots = [
            {
              store = "steam";
              path = "${home}/.local/share/Steam";
            }
            {
              store = "otherWine";
              path = "${home}/.var/app/com.usebottles.bottles/data/bottles/bottles/Games-Exe-Runner-Proton";
            }
          ];
          backup = {
            path = "${home}/Backups/ludusavi";
            retention.full = 40;
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
            path = "/Ludusavi/ludusavi-backup";
            synchronize = true;
          };
          apps.rclone.path = "rclone";
        };
      };
    };
}
