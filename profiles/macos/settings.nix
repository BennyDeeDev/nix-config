{
  darwin =
    { config, lib, ... }:
    {
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

        dock = {
          autohide = true;
          mru-spaces = false;
          show-recents = false;
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
      };

      system.activationScripts.postActivation.text = lib.mkAfter ''
        sudo -u ${config.system.primaryUser} \
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };
}
