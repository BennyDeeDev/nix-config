{
  home-manager,
  helixFlake,
  lazygitFlake,
  jovian,
  lanzaboote,
  nix-flatpak,
  nix-homebrew,
  plasma-manager,
  sops-nix,
  steamdex,
  self,
  ...
}:

let
  apps = import ./apps;
  gaming = import ./gaming {
    inherit jovian nix-flatpak self;
    steamdexFlake = steamdex;
  };
  nixos = import ./nixos { inherit sops-nix; };
  nixosDesktop = import ./nixos-desktop { inherit home-manager lanzaboote; };
  kde = import ./kde { inherit plasma-manager; };
  macos = import ./macos { inherit home-manager nix-homebrew; };
  pi = import ./pi;
  terminal = import ./terminal { inherit helixFlake lazygitFlake; };
in
{
  inherit
    apps
    gaming
    nixos
    nixosDesktop
    kde
    macos
    pi
    terminal
    ;
}
