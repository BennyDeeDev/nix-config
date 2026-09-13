{
  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      manifestPath = "${config.xdg.configHome}/steam-rom-manager/userData/manifests";
      settingsFormat = pkgs.formats.json { };

      systemManifest = [
        {
          title = "Microsoft Windows 11";
          target = "/run/current-system/sw/bin/systemctl";
          launchOptions = "--system start windows-reboot.service";
        }
      ];

      userConfigurations = [
        {
          parserType = "Manual";
          configTitle = "System Apps";
          parserId = "system-apps";
          titleFromVariable.limitToGroups = [ ];
          steamCategories = [ "System" ];
          steamInputEnabled = "2";
          disabled = true;
          parserInputs.manualManifests = "${manifestPath}/system";
        }
      ];
    in
    {
      programs.steam-rom-manager.userConfigurations = lib.mkAfter userConfigurations;

      xdg.configFile."steam-rom-manager/userData/manifests/system/system-apps.json".source =
        settingsFormat.generate "steam-rom-manager-system-apps.json" systemManifest;
    };
}
