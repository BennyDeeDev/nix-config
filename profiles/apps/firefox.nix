{
  homeManager =
    { lib, pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisableRemoteImprovements = true;
          DisableFirefoxAccounts = true;

          OverrideFirstRunPage = "";
          DontCheckDefaultBrowser = true;
          OfferToSaveLogins = false;

          DNSOverHTTPS = {
            Enabled = false;
          };

          FirefoxHome = {
            SponsoredTopSites = false;
            SponsoredStories = false;
          };

          ExtensionSettings."uBlock0@raymondhill.net" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
        };

        profiles.default = {
          id = 0;
          isDefault = true;
          settings = {
            "browser.startup.page" = 3;
            "browser.translations.alwaysTranslateLanguages" = "ru";
            "intl.regional_prefs.use_os_locales" = true;
            "media.videocontrols.picture-in-picture.enabled" = false;
            "signon.generation.enabled" = false;
            "signon.firefoxRelay.feature" = "disabled";
          };

          search = {
            force = true;
            default = "brave";
            privateDefault = "brave";

            engines.brave = {
              name = "Brave Search";

              urls = [
                {
                  template = "https://search.brave.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              definedAliases = [ "@brave" ];
            };
          };
        };
      };

      xdg = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        mimeApps = {
          enable = true;

          defaultApplications = {
            "text/html" = "firefox.desktop";
            "x-scheme-handler/http" = "firefox.desktop";
            "x-scheme-handler/https" = "firefox.desktop";
          };
        };
      };
    };
}
