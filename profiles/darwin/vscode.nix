{
  homeManager =
    { config, nixConfig, ... }:
    {
      home.file."Library/Application Support/Code/User/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/vscode/settings.json";
    };
}
