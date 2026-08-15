{
  dgop,
  dms,
  dms-plugin-registry,
}:

let
  apps = import ./apps.nix;
  darwin = import ./darwin.nix;
  dmsFeature = import ./dms.nix {
    inherit dgop dms dms-plugin-registry;
  };
  fonts = import ./fonts.nix;
  ghostty = import ./ghostty.nix;
  godot = import ./godot.nix;
  input = import ./input.nix;
  nautilus = import ./nautilus.nix;
  niri = import ./niri.nix;
  vscode = import ./vscode.nix;
  wayland = import ./wayland.nix;
  xdg = import ./xdg.nix;
in
{
  nixos = {
    imports = [
      apps.nixos
      dmsFeature.nixos
      input.nixos
      nautilus.nixos
      niri.nixos
      wayland.nixos
    ];
  };

  inherit (darwin) darwin;

  homeManager = {
    imports = [
      apps.homeManager
      darwin.homeManager
      dmsFeature.homeManager
      fonts.homeManager
      ghostty.homeManager
      godot.homeManager
      input.homeManager
      nautilus.homeManager
      niri.homeManager
      vscode.homeManager
      wayland.homeManager
      xdg.homeManager
    ];
  };
}
