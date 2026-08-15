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
  gnomeKeyring = import ./gnome-keyring.nix;
  gnomeDisks = import ./gnome-disks.nix;
  ghostty = import ./ghostty.nix;
  input = import ./input.nix;
  nautilus = import ./nautilus.nix;
  niri = import ./niri.nix;
  shares = import ./shares.nix;
  studioDisplay = import ./studio-display.nix;
  vscode = import ./vscode.nix;
  xdg = import ./xdg.nix;
  zsa = import ./zsa.nix;
in
{
  nixos = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.dconf.enable = true;
    security.polkit.enable = true;

    imports = [
      apps.nixos
      dmsFeature.nixos
      gnomeKeyring.nixos
      gnomeDisks.nixos
      input.nixos
      nautilus.nixos
      niri.nixos
      shares.nixos
      studioDisplay.nixos
      xdg.nixos
      zsa.nixos
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
        gnomeKeyring.homeManager
        input.homeManager
        nautilus.homeManager
        niri.homeManager
        shares.homeManager
        studioDisplay.homeManager
        vscode.homeManager
        xdg.homeManager
      ];
    };
}
