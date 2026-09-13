{
  homeManager =
    {
      config,
      pkgs,
      ...
    }:
    let
      manifestPath = "${config.xdg.configHome}/steam-rom-manager/userData/manifests";
      settingsFormat = pkgs.formats.json { };

      mediaManifest = [
        {
          title = "Stremio";
          target = "/usr/bin/env";
          launchOptions = "flatpak run com.stremio.Stremio";
        }
        {
          title = "Vacuum Tube";
          target = "/usr/bin/env";
          launchOptions = "flatpak run rocks.shy.VacuumTube";
        }
      ];

      userSettings = {
        environmentVariables = {
          steamDirectory = "${config.home.homeDirectory}/.local/share/Steam/";
          romsDirectory = config.my.gaming.gamesPath;
        };
      };

      userConfigurations = [
        {
          parserType = "Glob";
          configTitle = "Nintendo Switch - Ryujinx(Flatpak)";
          parserId = "nintendo-switch-ryujinx";
          romDirectory = "${config.my.gaming.gamesPath}/Switch";
          steamCategories = [ "Switch" ];
          executableArgs = "flatpak run io.github.ryubing.Ryujinx --fullscreen \"\${filePath}\"";
          executableModifier = "\"\${exePath}\"";
          steamInputEnabled = "0";
          disabled = true;
          parserInputs.glob = "\${title} \\[0100*000\\]\\[v0\\]*.@(nsp|NSP|xci|XCI|nca|NCA|nro|NRO|nso|NSO)";
          executable = {
            path = "/usr/bin/env";
            appendArgsToExecutable = true;
          };
        }
        {
          parserType = "Glob";
          configTitle = "PC - Bottles (Flatpak)";
          parserId = "pc-bottles";
          romDirectory = "${config.my.gaming.gamesPath}/PC";
          steamCategories = [ "PC - Bottles (Flatpak)" ];
          executableArgs = "flatpak run --command=bottles-cli --unshare=network com.usebottles.bottles run -b \"Games Exe Runner Proton\" -e \"\${filePath}\"";
          executableModifier = "\"\${exePath}\"";
          titleModifier = "\${/:/|\${title}|}";
          steamInputEnabled = "1";
          disabled = true;
          parserInputs.glob = "\${title}/{,!(NoDVD|_Redist|_CommonRedist|EasyAntiCheat|BattlEye|exec|Engine|AdvGuide|ArtbookOST|Gameface|Crashpad|ERD_ArtbookOST)/}!(unins*|*[Cc]rash*|*[Rr]eport*|crs-*|*[Ss]etup*|patcher*|*[Bb]enchmark*|*[Ll]anguage*|*[Mm]onitor*|*_EAC|RapidCRC*|*[Ss]hipping*|*DED*|*[Pp]rotected*|dxweb*|?*[Ll]auncher*|*32|*.profile).exe";
          executable = {
            path = "/usr/bin/env";
            appendArgsToExecutable = true;
          };
        }
        {
          parserType = "Manual";
          configTitle = "Desktop Media";
          parserId = "desktop-media";
          titleFromVariable.limitToGroups = [ ];
          steamCategories = [ "Media" ];
          steamInputEnabled = "2";
          parserInputs.manualManifests = "${manifestPath}/media";
        }
      ];
    in
    {
      programs.steam-rom-manager = {
        enable = true;
        accounts = [ "tfopgonehitgg" ];
        userSettings = userSettings;
        inherit userConfigurations;
      };

      xdg.configFile."steam-rom-manager/userData/manifests/media/media-apps.json".source =
        settingsFormat.generate "steam-rom-manager-media-apps.json" mediaManifest;
    };
}
