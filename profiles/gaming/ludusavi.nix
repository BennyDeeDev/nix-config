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
      sentinel = "${config.xdg.stateHome}/ludusavi/bootstraped";
    in
    {
      programs.rclone.enable = true;

      sops = {
        secrets = {
          "smb-username" = { };
          "smb-password-rclone-obscured" = { };
        };
        templates."rclone.conf" = {
          content = ''
            [ludusavi-1759601223]
            type = smb
            host = 192.168.178.254
            port = 445
            user = ${config.sops.placeholder."smb-username"}
            pass = ${config.sops.placeholder."smb-password-rclone-obscured"}
          '';
          path = "${config.xdg.configHome}/rclone/rclone.conf";
        };
      };

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
              id = "ludusavi-1759601223";
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

      systemd.user.services.ludusavi-bootstrap = {
        Unit = {
          Description = "Bootstrap Ludusavi backups from the NAS";
          ConditionPathExists = "!${sentinel}";
          Wants = [
            "network-online.target"
            "sops-nix.service"
          ];
          After = [
            "network-online.target"
            "sops-nix.service"
          ];
        };
        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "2min";
          StateDirectory = "ludusavi";
          ExecStart = "${lib.getExe pkgs.ludusavi} cloud download --force";
          ExecStartPost = "${lib.getExe' pkgs.coreutils "touch"} ${sentinel}";
        };
        Install.WantedBy = [ "default.target" ];
      };

      systemd.user.services.ludusavi.Unit = {
        Requires = [ "ludusavi-bootstrap.service" ];
        After = [ "ludusavi-bootstrap.service" ];
      };

      systemd.user.timers.ludusavi.Timer.Persistent = true;

      systemd.user.tmpfiles.rules = [
        "d ${home}/Backups/ludusavi 0700 - - -"
      ];
    };
}
