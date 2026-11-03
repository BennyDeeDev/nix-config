{
  homeManager =
    { lib, pkgs, ... }:
    {
      programs.firefox = {
        enable = true;
        configPath =
          if pkgs.stdenv.hostPlatform.isLinux then
            ".mozilla/firefox"
          else
            "Library/Application Support/org.nixos.firefox";
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisableRemoteImprovements = true;
          DisableFirefoxAccounts = true;

          OverrideFirstRunPage = "";
          SkipTermsOfUse = true;
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
            default_area = "navbar";
          };
          ExtensionSettings."{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            default_area = "navbar";
          };
        };

        profiles.default = {
          id = 0;
          isDefault = true;
          settings = {
            "browser.startup.page" = 3;
            "browser.warnOnQuit" = false;
            "browser.translations.alwaysTranslateLanguages" = "ru";
            "browser.translations.neverTranslateLanguages" = "de,en";
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
