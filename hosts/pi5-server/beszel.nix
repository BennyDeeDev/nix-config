{
  nixos = {
    services.beszel.hub = {
      enable = true;
      environment = {
        APP_URL = "https://stats.benjaminderksen.com";
        DISABLE_SSH = "true";
      };
    };
  };
}
