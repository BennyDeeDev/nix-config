{
  homeManager = {
    programs.zsh.siteFunctions = {
      z = ''
        zellij attach -c "$(basename "$PWD")" --force-run-commands
      '';

      zdev = ''
        zellij --layout dev attach -c "$(basename "$PWD")-dev" --force-run-commands
      '';
    };

    programs.zellij = {
      enable = true;

      settings = {
        theme_dark = "catppuccin-mocha";
        theme_light = "catppuccin-latte";
        show_startup_tips = false;
        show_release_notes = false;
      };

      extraConfig = ''
        keybinds {
            unbind "Alt f"

            locked {
                bind "Alt h" { MoveFocusOrTab "Left"; }
                bind "Alt l" { MoveFocusOrTab "Right"; }
                bind "Alt j" { MoveFocus "Down"; }
                bind "Alt k" { MoveFocus "Up"; }
            }

            shared {
                bind "Alt t" { ToggleFloatingPanes; }
            }
        }
      '';

      layouts.dev = ''
        layout {
          default_tab_template {
            pane size=1 borderless=true {
              plugin location="tab-bar"
            }

            children

            pane size=1 borderless=true {
              plugin location="status-bar"
            }
          }

          tab {
            pane split_direction="vertical" {
              pane size="40%" command="opencode" name="Opencode"

              pane size="60%" command="hx" name="Helix" focus=true {
                args "."
              }
            }
          }
        }
      '';
    };
  };
}
