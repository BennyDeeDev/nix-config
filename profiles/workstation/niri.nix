{ repoRoot, ... }:

{
  nixos = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };
    services.displayManager.defaultSession = "niri";
  };

  homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      xdg.configFile = {
        "niri/config.kdl".source = repoRoot + "/files/niri/config.kdl";
        "niri/envs.kdl".source = repoRoot + "/files/niri/envs.kdl";
        "niri/monitors.kdl".source = repoRoot + "/files/niri/monitors.kdl";
        "niri/input.kdl".source = repoRoot + "/files/niri/input.kdl";
        "niri/looknfeel.kdl".source = repoRoot + "/files/niri/looknfeel.kdl";
        "niri/bindings.kdl".source = repoRoot + "/files/niri/bindings.kdl";
        "niri/autostart.kdl".source = repoRoot + "/files/niri/autostart.kdl";
        "niri/rules.kdl".source = repoRoot + "/files/niri/rules.kdl";
      };
    };
}
