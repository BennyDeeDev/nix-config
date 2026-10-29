{
  nixos = {
    services.home-assistant = {
      enable = true;
      config = {
        default_config = { };
      };
      extraComponents = [
        "analytics"
        "default_config"
        "go2rtc"
        "google_translate"
        "matter"
        "met"
        "otbr"
        "radio_browser"
        "shopping_list"
        "thread"
      ];
    };

    my.restic.ha = {
      repository = "/mnt/nas/restic/ha-restic";
      path = "/var/lib/hass";
      service = "home-assistant.service";
      mountPoint = "/mnt/nas/restic";
    };
  };
}
