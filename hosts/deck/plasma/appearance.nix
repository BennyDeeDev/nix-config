{
  programs.plasma.configFile.kdeglobals.KDE = {
    AutomaticDarkLightLookAndFeel = true;
    LookAndFeelPackage = "org.kde.breeze.desktop";
    NightLookAndFeelPackage = "org.kde.breezedark.desktop";
  };

  programs.plasma.workspace.wallpaperCustomPlugin = {
    plugin = "org.kde.image";
    config.General = {
      DynamicMode = 1;
      Image = "file:///usr/share/wallpapers/Next/#day-night";
      SlidePaths = "/usr/share/wallpapers/";
    };
  };
}
