{
  programs.plasma.configFile.kdeglobals.KDE = {
    AutomaticLookAndFeel = true;
    DefaultDarkLookAndFeel = "org.kde.breezedark.desktop";
    DefaultLightLookAndFeel = "org.kde.breeze.desktop";
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
