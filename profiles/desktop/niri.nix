{
  nixos = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
    services.displayManager.defaultSession = "niri";
  };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.xwayland-satellite
      ];

      xdg.configFile = {
        "niri/config.kdl".source = ../../files/niri/config.kdl;
        "niri/envs.kdl".source = ../../files/niri/envs.kdl;
        "niri/monitors.kdl".source = ../../files/niri/monitors.kdl;
        "niri/input.kdl".source = ../../files/niri/input.kdl;
        "niri/looknfeel.kdl".source = ../../files/niri/looknfeel.kdl;
        "niri/bindings.kdl".source = ../../files/niri/bindings.kdl;
        "niri/autostart.kdl".source = ../../files/niri/autostart.kdl;
        "niri/rules.kdl".source = ../../files/niri/rules.kdl;
      };
    };
}
