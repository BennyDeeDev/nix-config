{
  dank-greeter,
  dms,
  dms-plugin-registry,
}:

{
  nixos =
    { config, ... }:
    let
      configHome = config.users.users.benjamin.home;
    in
    {
      imports = [ dank-greeter.nixosModules.default ];

      users.groups.greeter = { };
      users.users.greeter = {
        isSystemUser = true;
        group = "greeter";
      };

      services.greetd.settings.default_session.user = "greeter";

      services.upower.enable = true;

      programs.dms-greeter = {
        enable = true;
        compositor.name = "niri";
        configHome = configHome;
      };
    };

  homeManager =
    {
      config,
      nixConfig,
      pkgs,
      ...
    }:
    {
      imports = [
        dms.homeModules.dank-material-shell
        dms-plugin-registry.homeModules.default
      ];

      xdg.configFile = {
        "dms/wallpapers/dark.png".source = config.lib.file.mkOutOfStoreSymlink (
          "${nixConfig}/files/images/dark.png"
        );
        "dms/wallpapers/light.png".source = config.lib.file.mkOutOfStoreSymlink (
          "${nixConfig}/files/images/light.png"
        );
        "DankMaterialShell/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/dms/settings.json";
      };

      programs.dank-material-shell = {
        enable = true;
        systemd = {
          enable = true;
          target = "niri.service";
          restartIfChanged = true;
        };
        enableSystemMonitoring = true;
        enableVPN = false;
        enableDynamicTheming = false;
        enableAudioWavelength = true;
        enableCalendarEvents = true;
      };

      systemd.user.services.dms.Service.Environment = [
        "GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"
      ];
    };
}
