{
  programs.plasma.configFile.kdeglobals.KDE = {
    AutomaticDarkLightLookAndFeel = true;
    LookAndFeelPackage = "org.kde.breeze.desktop";
    NightLookAndFeelPackage = "org.kde.breezedark.desktop";
  };

  programs.plasma.configFile = {
    "ktimezonedrc".TimeZones.LocalZone = "Europe/Berlin";

    "plasma-localerc".Formats = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "en_DE.UTF-8";
    };
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
