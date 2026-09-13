{
  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      systemManifest = [
        {
          title = "Microsoft Windows 11";
          target = "/run/current-system/sw/bin/systemctl";
          launchOptions = "--system start windows-reboot.service";
        }
      ];
    in
    {
      programs.steam-rom-manager.userConfigurations = lib.mkAfter [
        {
          version = 29;
          parserType = "Manual";
          configTitle = "System Apps";
          parserId = "system-apps";
          titleFromVariable.limitToGroups = [ ];
          userAccounts.specifiedAccounts = [ "Global" ];
          steamCategories = [ "System" ];
          steamInputEnabled = "2";
          disabled = true;
          parserInputs.manualManifests = "${config.xdg.configHome}/steam-rom-manager/userData/manifests/system";
        }
      ];

      xdg.configFile."steam-rom-manager/userData/manifests/system/system-apps.json".source =
        (pkgs.formats.json { }).generate "steam-rom-manager-system-apps.json"
          systemManifest;
    };
}
