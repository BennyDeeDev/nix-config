{
  homeManager =
    { config, nixConfig, ... }:
    {
      home.file = {
        "Library/Application Support/Code/User/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/vscode/settings.json";
        "Library/Application Support/Code/User/mcp.json".source =
          config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/vscode/mcp.json";
      };
    };
}
