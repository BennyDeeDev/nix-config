{ config, ... }:

{
  programs.plasma.configFile.kdeglobals.KDE = {
    AutomaticDarkLightLookAndFeel = true;
    LookAndFeelPackage = "org.kde.breeze.desktop";
    NightLookAndFeelPackage = "org.kde.breezedark.desktop";
  };

  programs.plasma.configFile = {
    "ktimezonedrc".TimeZones.LocalZone = "Europe/Berlin";

    "plasma-localerc".Formats = {
      LC_ADDRESS = config.home.language.address;
      LC_MEASUREMENT = config.home.language.measurement;
      LC_MONETARY = config.home.language.monetary;
      LC_NAME = config.home.language.name;
      LC_NUMERIC = config.home.language.numeric;
      LC_PAPER = config.home.language.paper;
      LC_TELEPHONE = config.home.language.telephone;
      LC_TIME = config.home.language.time;
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
