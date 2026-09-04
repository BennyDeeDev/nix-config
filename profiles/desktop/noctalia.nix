{
  noctalia,
  noctalia-greeter,
}:

{
  nixos = {
    imports = [ noctalia-greeter.nixosModules.default ];

    users.groups.greeter = { };
    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
    };

    services.greetd.settings.default_session.user = "greeter";
    services.upower.enable = true;

    programs.noctalia-greeter = {
      enable = true;
      settings = {
        session.default = "niri";
        appearance = {
          scheme = "Catppuccin";
          wallpaper = {
            path = builtins.toString ../../files/images/dark.png;
            fill_mode = "crop";
          };
        };
        cursor = {
          theme = "Adwaita";
          size = 24;
        };
        keyboard = {
          layout = "us";
          options = "compose:ralt";
          numlock = true;
        };
      };
    };
  };

  homeManager =
    { config, ... }:
    {
      imports = [ noctalia.homeModules.default ];

      xdg.configFile = {
        "noctalia/wallpapers/dark/dark.png".source = ../../files/images/dark.png;
        "noctalia/wallpapers/light/light.png".source = ../../files/images/light.png;
      };

      programs.noctalia = {
        enable = true;
        # settings = ../../files/noctalia/config.toml;
        settings = {
        };
      };
    };
}
