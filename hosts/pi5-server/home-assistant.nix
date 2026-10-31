{
  nixos =
    { pkgs, ... }:
    {
      services.home-assistant = {
        enable = true;
        themes = [ pkgs.home-assistant-themes.catppuccin ];
        config = {
          default_config = { };

          homeassistant.auth_providers = [
            {
              type = "trusted_networks";
              trusted_networks = [ "192.168.178.54/32" ];
              trusted_users."192.168.178.54" = "83f2b0d4b9bf413e8161fc5acd3bbab5";
              allow_bypass_login = true;
            }
            { type = "homeassistant"; }
          ];
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
