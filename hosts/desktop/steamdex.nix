{
  homeManager =
    { config, ... }:
    let
      gamesPath = config.my.gaming.gamesPath;
      portableGamesPath = config.my.gaming.portableGamesPath;
      switchGlobs = [ ''* \[0100*000\]\[v0\]*.{nsp,NSP,xci,XCI,nca,NCA,nro,NRO,nso,NSO}'' ];
    in
    {
      my.steamdex.settings = {
        parsers = [
          {
            name = "Nintendo Switch - Eden (30 FPS)";
            enabled = true;
            title_from = "root_child_directory";
            directories = [
              "${gamesPath}/Switch/30fps"
              "${portableGamesPath}/Switch/30fps"
            ];
            globs = switchGlobs;
            steam_shortcut = {
              executable = "/etc/profiles/per-user/benjamin/bin/eden-rog-ally-pgo";
              launch_options = ''LD_PRELOAD="" /etc/profiles/per-user/benjamin/bin/lsfg-vk-4x %command% -f -g "''${file_path}"'';
              categories = [ "Switch" ];
            };
          }

          {
            name = "Nintendo Switch - Eden (60 FPS)";
            enabled = true;
            title_from = "root_child_directory";
            directories = [
              "${gamesPath}/Switch/60fps"
              "${portableGamesPath}/Switch/60fps"
            ];
            globs = switchGlobs;
            steam_shortcut = {
              executable = "/etc/profiles/per-user/benjamin/bin/eden-rog-ally-pgo";
              launch_options = ''LD_PRELOAD="" /etc/profiles/per-user/benjamin/bin/lsfg-vk-2x %command% -f -g "''${file_path}"'';
              categories = [ "Switch" ];
            };
          }

          {
            name = "PC Bottles Local";
            enabled = true;
            title_from = "root_child_directory";
            directories = [ "${gamesPath}/PC" ];
            globs = [ "my.launcher.bat" ];
            steam_shortcut = {
              executable = "/usr/bin/env";
              launch_options = ''flatpak run --command=bottles-cli --unshare=network com.usebottles.bottles run -b "gaming-bottle" -e "''${file_path}"'';
              categories = [ "PC Bottles Local" ];
            };
          }

          {
            name = "PC Bottles Portable";
            enabled = true;
            title_from = "root_child_directory";
            directories = [ "${portableGamesPath}/PC" ];
            globs = [ "my.launcher.bat" ];
            steam_shortcut = {
              executable = "/usr/bin/env";
              launch_options = ''flatpak run --command=bottles-cli --unshare=network com.usebottles.bottles run -b "gaming-portable-bottle" -e "''${file_path}"'';
              categories = [ "PC Bottles Portable" ];
            };
          }
        ];

        apps = [
          {
            title = "Stremio";
            steam_shortcut = {
              executable = "/usr/bin/env";
              launch_options = "flatpak run com.stremio.Stremio";
              categories = [ "Media" ];
            };
          }

          {
            title = "Vacuum Tube";
            steam_shortcut = {
              executable = "/etc/profiles/per-user/benjamin/bin/VacuumTube";
              categories = [ "Media" ];
            };
          }

          {
            title = "Microsoft Windows 11";
            steam_shortcut = {
              executable = "/run/current-system/sw/bin/systemctl";
              launch_options = "--system start windows-reboot.service";
              categories = [ "System" ];
            };
          }
        ];
      };
    };
}
