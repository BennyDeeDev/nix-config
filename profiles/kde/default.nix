{ plasma-manager }:

let
  localeModule = import ../../modules/locale.nix;
  extraPackages =
    pkgs: with pkgs; [
      kdePackages.kcalc
      kdePackages.kcharselect
      kdePackages.kclock
      kdePackages.kcolorchooser
      kdePackages.kolourpaint
      kdePackages.ksystemlog
      kdePackages.sddm-kcm
      kdiff3
      kdePackages.isoimagewriter
      kdePackages.partitionmanager
      hardinfo2
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
      imports = [
        localeModule.homeManager
        plasma-manager.homeModules.plasma-manager
        ./look-and-feel.nix
        ./panels.nix
        ./regional.nix
        ./shortcuts.nix
      ];

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
