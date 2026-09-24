{
  homeManager =
    {
      pkgs,
      ...
    }:
    {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = true;
        package = pkgs.vscode;
        profiles.default = {
          mutableUserSettings = true;
          userSettings = {
            "workbench.iconTheme" = "catppuccin-latte";
            "workbench.startupEditor" = "none";
            "workbench.layoutControl.enabled" = false;
            "workbench.secondarySideBar.defaultVisibility" = "visible";
            "workbench.preferredLightColorTheme" = "Catppuccin Latte";
            "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
            "workbench.browser.showInTitleBar" = true;

            "window.commandCenter" = false;
            "window.confirmSaveUntitledWorkspace" = false;
            "window.autoDetectColorScheme" = true;
            "window.title" = "\${folderName}\${separator}\${activeEditorShort}";
            "window.titleSeparator" = " — ";

            "editor.fontFamily" = "Hack Nerd Font Mono";
            "editor.fontSize" = 13;
            "editor.formatOnSave" = true;
            "editor.inlayHints.enabled" = "off";
            "editor.accessibilitySupport" = "off";

            "diffEditor.ignoreTrimWhitespace" = false;

            "explorer.confirmDragAndDrop" = false;
            "explorer.confirmDelete" = false;

            "security.workspace.trust.untrustedFiles" = "open";

            "git.enableSmartCommit" = true;
            "git.confirmSync" = false;

            "[jsonc]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[json]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[markdown]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[css]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[javascript]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[typescript]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[typescriptreact]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[html]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };

            "typescript.updateImportsOnFileMove.enabled" = "always";
            "go.toolsManagement.autoUpdate" = true;

            "github.copilot.enable" = {
              "*" = false;
            };
            "chat.commandCenter.enabled" = false;
            "chat.viewWelcome.enabled" = false;
            "chat.viewSessions.orientation" = "stacked";
            "chat.agent.maxRequests" = 50;
            "chat.permissions.default" = "autoApprove";
            "chat.titleBar.signIn.enabled" = false;
            "chat.titleBar.openInAgentsWindow.enabled" = false;
            "accessibility.signalOptions.volume" = 25;
            "accessibility.signals.chatResponseReceived" = {
              sound = "on";
            };
            "accessibility.signals.chatUserActionRequired" = {
              sound = "on";
            };

            "telemetry.feedback.enabled" = false;
            "telemetry.telemetryLevel" = "off";
            "telemetry.editStats.enabled" = false;
          };
          userMcp = {
            servers = {
              exa = {
                type = "http";
                url = "https://mcp.exa.ai/mcp";
              };
              parallel = {
                type = "http";
                url = "https://search.parallel.ai/mcp";
              };
            };
          };
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
