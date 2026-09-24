{
  homeManager =
    { config, ... }:
    let
      homeLanguage = config.home.language;
    in
    {
      programs.plasma.configFile = {
        "ktimezonedrc".TimeZones.LocalZone = "Europe/Berlin";

        "plasma-localerc".Formats = {
          LC_ADDRESS = homeLanguage.address;
          LC_MEASUREMENT = homeLanguage.measurement;
          LC_MONETARY = homeLanguage.monetary;
          LC_NAME = homeLanguage.name;
          LC_NUMERIC = homeLanguage.numeric;
          LC_PAPER = homeLanguage.paper;
          LC_TELEPHONE = homeLanguage.telephone;
          LC_TIME = homeLanguage.time;
        };
      };
    };
}
