{
  dgop,
  dms,
  dms-plugin-registry,
}:

{
  nixos = {
    imports = [ dms.nixosModules.greeter ];

    users.groups.greeter = { };
    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
    };

    services.greetd.settings.default_session.user = "greeter";

    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/benjamin";
    };
  };

  homeManager =
    {
      config,
      dotfiles,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        dms.homeModules.dank-material-shell
        dms-plugin-registry.homeModules.default
      ];

      config = lib.mkIf pkgs.stdenv.isLinux {
        xdg.configFile = {
          "dms/wallpapers/dark.png".source = config.lib.file.mkOutOfStoreSymlink (
            "${dotfiles}/files/images/dark.png"
          );
          "dms/wallpapers/light.png".source = config.lib.file.mkOutOfStoreSymlink (
            "${dotfiles}/files/images/light.png"
          );
          "DankMaterialShell/settings.json".source =
            config.lib.file.mkOutOfStoreSymlink "${dotfiles}/files/dms/settings.json";
        };

        programs.dank-material-shell = {
          enable = true;
          systemd = {
            enable = true;
            restartIfChanged = true;
          };
          enableSystemMonitoring = true;
          dgop.package = dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
          enableVPN = false;
          enableDynamicTheming = false;
          enableAudioWavelength = true;
          enableCalendarEvents = true;
          plugins = { };
        };
      };
    };
}
