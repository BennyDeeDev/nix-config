{
  homeManager =
    { config, dotfiles, ... }:
    {
      home.file."Library/Application Support/Code/User/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/files/vscode/settings.json";
    };
}
