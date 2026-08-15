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

      programs.zsh.initContent = ''
        vcd() { __cd_and_exec code -r .; }
        vcda() { __cd_and_exec code --add .; }

        vcdr() {
          local folders selected full_path
          folders=$(code --status 2>/dev/null | sed -n 's/.*Folder (\(.*\)):.*/\1/p')

          [[ -z "$folders" ]] && {
            echo "No workspace folders found."
            return 0
          }

          selected=$(echo "$folders" | fzf) || return 0
          [[ -z "$selected" ]] && return 0

          if [[ -d "$HOME/Repos/$selected" ]]; then
            full_path="$HOME/Repos/$selected"
          elif [[ -d "$HOME/.config/$selected" ]]; then
            full_path="$HOME/.config/$selected"
          else
            echo "Could not find: $selected"
            return 1
          fi

          code --remove "$full_path"
        }

        tasksjson() {
          mkdir -p .vscode
          cat > .vscode/tasks.json << 'EOF'
        {
          "version": "2.0.0",
          "tasks": [
            {
              "label": "My Placeholder Task",
              "type": "shell",
              "command": "echo 'Hello, World!'",
              "problemMatcher": []
            }
          ]
        }
        EOF
        }
      '';
    };
}
