{
  homeManager = {
    programs.zsh.siteFunctions = {
      z = ''
        zellij --layout dev attach -c "$(basename "$PWD")" --force-run-commands
      '';
    };

    programs.zellij = {
      enable = true;

      settings = {
        default_mode = "locked";
        theme_dark = "catppuccin-mocha";
        theme_light = "catppuccin-latte";
        show_startup_tips = false;
        show_release_notes = false;
        support_kitty_keyboard_protocol = false;
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

          tab name="code" focus=true {
            pane split_direction="vertical" {
              pane size="30%" name="Shell"

              pane size="70%" command="hx" name="Helix" focus=true {
                args "."
              }
            }
          }

          tab name="git" {
            pane command="lazygit" name="LazyGit"
          }

          tab name="ai" {
            pane command="opencode" name="Opencode"
          }
        }
      '';
    };
  };
}
