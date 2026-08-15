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
  ghostty = import ./ghostty.nix;
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

  homeManager = {
    imports = [
      apps.homeManager
      dmsFeature.homeManager
      fonts.homeManager
      ghostty.homeManager
      input.homeManager
      nautilus.homeManager
      niri.homeManager
      vscode.homeManager
      wayland.homeManager
      xdg.homeManager
    ];
  };
}
