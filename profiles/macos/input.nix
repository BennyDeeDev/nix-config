let
  esc = builtins.fromJSON ''"\u001b"'';
in
{
  darwin = {
    system.defaults = {
      ".GlobalPreferences"."com.apple.mouse.scaling" = 0.875;

      trackpad = {
        TrackpadThreeFingerHorizSwipeGesture = 2;
        TrackpadThreeFingerVertSwipeGesture = 2;
      };

      CustomUserPreferences = {
        "com.apple.HIToolbox".AppleEnabledInputSources = [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 0;
            "KeyboardLayout Name" = "U.S.";
          }
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 3;
            "KeyboardLayout Name" = "German";
          }
        ];

        "com.apple.HIToolbox".AppleGlobalTextInputProperties = {
          TextInputGlobalPropertyPerContextInput = false;
        };

        NSGlobalDomain.NSUserKeyEquivalents = {
          "${esc}Window${esc}Move & Resize${esc}Left" = "@^~$h";
          "${esc}Window${esc}Move & Resize${esc}Bottom" = "@^~$j";
          "${esc}Window${esc}Move & Resize${esc}Top" = "@^~$k";
          "${esc}Window${esc}Move & Resize${esc}Right" = "@^~$l";
          "${esc}Window${esc}Fill" = "@^~m";
          "${esc}Window${esc}Center" = "@^~c";
          "${esc}Window${esc}Move & Resize${esc}Return to Previous Size" = "@^~r";
        };

        "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
          # Symbolic hotkey IDs map to macOS system actions. `parameters` stores
          # the key code and modifier mask; Control + Option + Command is 1835008.
          # 32: Mission Control — Hyper + W.
          "32" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                119
                13
                1835008
              ];
            };
          };
          # 36: Show Desktop — Hyper + D.
          "36" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                100
                2
                1835008
              ];
            };
          };
          # 118–127: Switch to Desktop 1–10 — Control + 1–0.
          "118" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                18
                262144
              ];
            };
          };
          # Switch to Desktop 2 — Control + 2.
          "119" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                19
                262144
              ];
            };
          };
          # Switch to Desktop 3 — Control + 3.
          "120" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                20
                262144
              ];
            };
          };
          # Switch to Desktop 4 — Control + 4.
          "121" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                21
                262144
              ];
            };
          };
          # Switch to Desktop 5 — Control + 5.
          "122" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                23
                262144
              ];
            };
          };
          # Switch to Desktop 6 — Control + 6.
          "123" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                22
                262144
              ];
            };
          };
          # Switch to Desktop 7 — Control + 7.
          "124" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                26
                262144
              ];
            };
          };
          # Switch to Desktop 8 — Control + 8.
          "125" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                28
                262144
              ];
            };
          };
          # Switch to Desktop 9 — Control + 9.
          "126" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                25
                262144
              ];
            };
          };
          # Switch to Desktop 10 — Control + 0.
          "127" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                29
                262144
              ];
            };
          };
        };

        NSGlobalDomain."com.apple.mouse.linear" = true;
      };
    };
  };
}
