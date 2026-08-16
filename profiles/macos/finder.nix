{
  darwin = {
    system.defaults = {
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

      CustomUserPreferences."com.apple.finder" = {
        FinderSpawnTab = false;
        ShowRecentTags = false;
      };
    };
  };
}
