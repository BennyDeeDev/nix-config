{
  dgop,
  dms,
  dms-plugin-registry,
}:

let
  apps = import ./apps.nix;
  dmsFeature = import ./dms.nix {
    inherit dgop dms dms-plugin-registry;
  };
  fonts = import ./fonts.nix;
  graphical = import ./graphical.nix;
  gnomeDisks = import ./gnome-disks.nix;
  ghostty = import ./ghostty.nix;
  godot = import ./godot.nix;
  input = import ./input.nix;
  nautilus = import ./nautilus.nix;
  niri = import ./niri.nix;
  studioDisplay = import ./studio-display.nix;
  vscode = import ./vscode.nix;
  xdg = import ./xdg.nix;
in
{
  nixos =
    { pkgs, ... }:
    {
    imports = [
      apps.nixos
      dmsFeature.nixos
      graphical.nixos
      gnomeDisks.nixos
      input.nixos
      nautilus.nixos
      niri.nixos
      studioDisplay.nixos
      xdg.nixos
    ];

  };

  inherit (apps) darwin;

  homeManager =
    { ... }:
    {
      imports = [
        apps.homeManager
        dmsFeature.homeManager
        fonts.homeManager
        ghostty.homeManager
        godot.homeManager
        input.homeManager
        nautilus.homeManager
        niri.homeManager
        studioDisplay.homeManager
        vscode.homeManager
        xdg.homeManager
      ];
    };
}
