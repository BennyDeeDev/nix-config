{ config, ... }:

{
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
}
