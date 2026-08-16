{
  homeManager =
    {
      config,
      nixConfig,
      lib,
      ...
    }:
    {
      home.file = {
        ".config/Code/User/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/vscode/settings.json";
        ".config/Code/User/keybindings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/vscode/keybindings-linux.json";
      };

      home.activation.vscodeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.vscode"
        cp ${../../files/vscode/argv-linux.json} "$HOME/.vscode/argv.json"
        chmod 644 "$HOME/.vscode/argv.json"
      '';
    };
}
