{ config, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleIconAppearanceTheme = "RegularAutomatic";
      AppleInterfaceStyleSwitchesAutomatically = true;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      "com.apple.swipescrolldirection" = false;
    };

    ".GlobalPreferences"."com.apple.mouse.scaling" = 0.875;

    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
    };

    trackpad = {
      TrackpadThreeFingerHorizSwipeGesture = 2;
      TrackpadThreeFingerVertSwipeGesture = 2;
    };

    finder = {
      _FXShowPosixPathInTitle = true;
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "Nlsv";
      NewWindowTarget = "Home";
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
    };

    controlcenter = {
      AirDrop = false;
      Bluetooth = true;
      Display = true;
      FocusModes = false;
      NowPlaying = false;
      Sound = false;
      BatteryShowPercentage = true;
    };

    menuExtraClock = {
      ShowAMPM = true;
      ShowDate = 1;
      ShowDayOfWeek = true;
    };

    universalaccess.reduceMotion = true;

    WindowManager = {
      EnableTiledWindowMargins = true;
      StandardHideWidgets = true;
    };

    CustomUserPreferences = {
      "com.apple.HIToolbox" = {
        AppleEnabledInputSources = [
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
        AppleSelectedInputSources = [
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 0;
            "KeyboardLayout Name" = "U.S.";
          }
        ];
      };
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Fn+F1: Switch to Space 1.
          "118" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                122
                8388608
              ];
            };
          };

          # Fn+F2: Switch to Space 2.
          "119" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                120
                8388608
              ];
            };
          };

          # Fn+F3: Switch to Space 3.
          "120" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                99
                8388608
              ];
            };
          };

          # Fn+F4: Switch to Space 4.
          "121" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                118
                8388608
              ];
            };
          };

          # Fn+F5: Switch to Space 5.
          "122" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                96
                8388608
              ];
            };
          };

          # Fn+F6: Switch to Space 6.
          "123" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                97
                8388608
              ];
            };
          };

          # Fn+F7: Switch to Space 7.
          "124" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                98
                8388608
              ];
            };
          };

          # Fn+F8: Switch to Space 8.
          "125" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                100
                8388608
              ];
            };
          };

          # Fn+F9: Switch to Space 9.
          "126" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                101
                8388608
              ];
            };
          };

          # Fn+F10: Switch to Space 10.
          "127" = {
            enabled = true;
            value = {
              type = "standard";
              parameters = [
                65535
                109
                8388608
              ];
            };
          };
        };
      };
      NSGlobalDomain = {
        "com.apple.mouse.linear" = true;
      };
      "com.apple.finder" = {
        FinderSpawnTab = false;
        ShowRecentTags = false;
      };
    };
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    sudo -u ${config.system.primaryUser} \
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  homebrew = {
    enable = true;
    taps = [
      {
        name = "TheBoredTeam/boring-notch";
        trusted = true;
      }
    ];
    casks = [
      "boring-notch"
      "ghostty"
      "stats"
    ];
    onActivation.cleanup = "uninstall";
  };
}
