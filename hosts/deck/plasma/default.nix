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
