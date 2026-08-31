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

        "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
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
