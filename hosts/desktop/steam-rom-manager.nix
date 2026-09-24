{
  homeManager =
    {
      config,
      nixConfig,
      ...
    }:
    let
      configDir = "${nixConfig}/hosts/desktop/files/steam-rom-manager";
      mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      home.file = {
        ".config/steam-rom-manager/userData/userSettings.json".source =
          mkOutOfStoreSymlink "${configDir}/userSettings.json";
        ".config/steam-rom-manager/userData/userConfigurations.json".source =
          mkOutOfStoreSymlink "${configDir}/userConfigurations.json";
        ".config/steam-rom-manager/userData/manifests/media/media-apps.json".source =
          mkOutOfStoreSymlink "${configDir}/manifests/media/media-apps.json";
        ".config/steam-rom-manager/userData/manifests/system/system-apps.json".source =
          mkOutOfStoreSymlink "${configDir}/manifests/system/system-apps.json";
      };
    };
}
