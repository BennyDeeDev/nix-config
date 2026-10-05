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
        # Avoid Ghostty's Cmd+C being interpreted as a literal "c" by Zellij.
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
                bind "Alt 1" { GoToTab 1; }
                bind "Alt 2" { GoToTab 2; }
                bind "Alt 3" { GoToTab 3; }
                bind "Alt 4" { GoToTab 4; }
                bind "Alt 5" { GoToTab 5; }
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
            pane split_direction="vertical" {
              pane size="30%" name="Shell"

              pane size="70%" command="opencode" name="Opencode" focus=true
            }
          }
        }
      '';
    };
  };
}
