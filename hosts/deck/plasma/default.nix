{ plasma-manager }:

{
  homeManager = {
    imports = [
      plasma-manager.homeModules.plasma-manager
      ./appearance.nix
      ./panels.nix
      ./shortcuts.nix
    ];

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
}
