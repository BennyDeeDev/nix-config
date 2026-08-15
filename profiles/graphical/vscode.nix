{
  homeManager =
    {
      pkgs,
      lib,
      config,
      dotfiles,
      ...
    }:
    let
      userDir =
        if pkgs.stdenv.isLinux then ".config/Code/User" else "Library/Application Support/Code/User";
    in
    {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        package = pkgs.vscode;
        profiles.default.extensions = with pkgs.vscode-extensions; [
          github.copilot-chat
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          esbenp.prettier-vscode
          jnoortheen.nix-ide
        ];
      };

      home.file = {
        "${userDir}/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfiles}/files/vscode/settings.json";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        "${userDir}/keybindings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfiles}/files/vscode/keybindings-linux.json";
      };

      home.activation.vscodeConfig = lib.mkIf pkgs.stdenv.isLinux (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.vscode"
          cp ${../../files/vscode/argv-linux.json} "$HOME/.vscode/argv.json"
          chmod 644 "$HOME/.vscode/argv.json"
        ''
      );
    };
}
