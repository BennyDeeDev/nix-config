let
  baseLocale = "en_US.UTF-8";
  extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_CTYPE = "de_DE.UTF-8";
    LC_COLLATE = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MESSAGES = baseLocale;
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  localeSettings = extraLocaleSettings // {
    LANG = baseLocale;
  };
  homeLanguage = {
    base = baseLocale;
    ctype = extraLocaleSettings.LC_CTYPE;
    collate = extraLocaleSettings.LC_COLLATE;
    numeric = extraLocaleSettings.LC_NUMERIC;
    time = extraLocaleSettings.LC_TIME;
    monetary = extraLocaleSettings.LC_MONETARY;
    messages = extraLocaleSettings.LC_MESSAGES;
    paper = extraLocaleSettings.LC_PAPER;
    name = extraLocaleSettings.LC_NAME;
    address = extraLocaleSettings.LC_ADDRESS;
    telephone = extraLocaleSettings.LC_TELEPHONE;
    measurement = extraLocaleSettings.LC_MEASUREMENT;
  };
in
{
  nixos = {
    time.timeZone = "Europe/Berlin";

    i18n = {
      defaultLocale = baseLocale;
      inherit extraLocaleSettings;
    };

    console.keyMap = "us";
  };

  homeManager = {
    home.language = homeLanguage;
    systemd.user.sessionVariables = localeSettings;
  };
}
