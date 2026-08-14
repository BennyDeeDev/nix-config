{ inputs, ... }:

{
  nixos = { ... }: {
    services.displayManager.dms-greeter = {
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
        inputs.dms.homeModules.dank-material-shell
        inputs.dms-plugin-registry.nixosModules.default
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
          dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
          enableVPN = false;
          enableDynamicTheming = false;
          enableAudioWavelength = true;
          enableCalendarEvents = true;
          plugins = { };
        };
      };
    };
}
