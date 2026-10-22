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
              "${portableGamesPath}/Switch/30fps"
              "${gamesPath}/Switch/30fps"
            ];
            globs = switchGlobs;
            steam_shortcut = {
              executable = "/home/deck/.nix-profile/bin/eden-steamdeck-pgo";
              launch_options = ''/home/deck/.nix-profile/bin/lsfg-vk-2x %command% -f -g "''${file_path}"'';
              categories = [ "Switch" ];
            };
          }

          {
            name = "Nintendo Switch - Eden (60 FPS)";
            enabled = true;
            title_from = "root_child_directory";
            directories = [
              "${portableGamesPath}/Switch/60fps"
              "${gamesPath}/Switch/60fps"
            ];
            globs = switchGlobs;
            steam_shortcut = {
              executable = "/home/deck/.nix-profile/bin/eden-steamdeck-pgo";
              launch_options = ''%command% -f -g "''${file_path}"'';
              categories = [ "Switch" ];
            };
          }

          {
            name = "PC - Bottles (Flatpak)";
            enabled = true;
            title_from = "root_child_directory";
            directories = [ "${portableGamesPath}/PC" ];
            globs = [ "my.launcher.bat" ];
            steam_shortcut = {
              executable = "/home/deck/.nix-profile/bin/steam-host";
              launch_options = ''flatpak run --command=bottles-cli --unshare=network com.usebottles.bottles run -b "gaming-portable-bottle" -e "''${file_path}"'';
              categories = [ "PC - Bottles" ];
            };
          }
        ];

        apps = [
          {
            title = "Stremio";
            steam_shortcut = {
              executable = "/home/deck/.nix-profile/bin/steam-host";
              launch_options = "flatpak run com.stremio.Stremio";
              categories = [ "Media" ];
            };
          }

          {
            title = "Vacuum Tube";
            steam_shortcut = {
              executable = "/home/deck/.nix-profile/bin/steam-host";
              launch_options = "/home/deck/.nix-profile/bin/VacuumTube";
              categories = [ "Media" ];
            };
          }

          {
            title = "Steam Link";
            steam_shortcut = {
              executable = "/home/deck/.nix-profile/bin/steam-host";
              launch_options = "flatpak run com.valvesoftware.SteamLink";
              categories = [ "Media" ];
            };
          }
        ];
      };
    };
}
