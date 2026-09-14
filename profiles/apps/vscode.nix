{
  homeManager =
    {
      config,
      lib,
      nixConfig,
      pkgs,
      ...
    }:
    let
      vscodeConfig = "${nixConfig}/files/vscode";
    in
    {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        package = pkgs.vscode;
        profiles.default = {
          userSettings = config.lib.file.mkOutOfStoreSymlink "${vscodeConfig}/settings.json";
          userMcp = config.lib.file.mkOutOfStoreSymlink "${vscodeConfig}/mcp.json";
          keybindings = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
            config.lib.file.mkOutOfStoreSymlink "${vscodeConfig}/keybindings-linux.json"
          );
          extensions = with pkgs.vscode-extensions; [
            github.copilot-chat
            catppuccin.catppuccin-vsc
            catppuccin.catppuccin-vsc-icons
            esbenp.prettier-vscode
            jnoortheen.nix-ide
            dbaeumer.vscode-eslint
            golang.go
            mikestead.dotenv
          ];
        };
      };
    };
}
