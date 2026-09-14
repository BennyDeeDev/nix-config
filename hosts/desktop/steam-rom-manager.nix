{
  homeManager =
    {
      config,
      nixConfig,
      ...
    }:
    let
      configDir = "${nixConfig}/hosts/desktop/files/steam-rom-manager";
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      home.file = {
        ".config/steam-rom-manager/userData/userSettings.json".source =
          link "${configDir}/userSettings.json";
        ".config/steam-rom-manager/userData/userConfigurations.json".source =
          link "${configDir}/userConfigurations.json";
        ".config/steam-rom-manager/userData/manifests/media/media-apps.json".source =
          link "${configDir}/manifests/media/media-apps.json";
        ".config/steam-rom-manager/userData/manifests/system/system-apps.json".source =
          link "${configDir}/manifests/system/system-apps.json";
      };
    };
}
