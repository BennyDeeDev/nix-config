let
  extraPackages =
    pkgs: with pkgs; [
      wayland-utils
      wl-clipboard
      haruna
    ];
  nixosPackages = pkgs: extraPackages pkgs ++ [ pkgs.kdePackages.filelight ];
in
{
  nixos =
    { pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.wayland.enable = true;
      programs.kdeconnect.enable = true;

      environment.plasma6.excludePackages = with pkgs; [
        kdePackages.elisa
        kdePackages.kmahjongg
        kdePackages.kmines
        kdePackages.kpat
        kdePackages.ksudoku
        kdePackages.khelpcenter
        kdePackages.kwin-x11
      ];

      environment.systemPackages = nixosPackages pkgs;
    };

  homeManager =
    {
      lib,
      pkgs,
      ...
    }:
    {
      options.my.kde.kickoffIcon = lib.mkOption {
        type = lib.types.str;
        default = "start-here";
        description = "Icon used by the KDE application launcher.";
      };

      config = {
        home.packages = extraPackages pkgs;

        programs.plasma = {
          enable = true;
          overrideConfig = true;

          configFile.dolphinrc.General.GlobalViewProps = true;
          dataFile."dolphin/view_properties/global/.directory".Dolphin.ViewMode = 1;

          input.keyboard = {
            repeatRate = 25;
            repeatDelay = 150;
          };

          session.sessionRestore.restoreOpenApplicationsOnLogin = "onLastLogout";

          kwin = {
            effects.desktopSwitching.animation = "off";
            virtualDesktops = {
              number = 10;
              rows = 1;
            };
          };
        };
      };
    };
}
