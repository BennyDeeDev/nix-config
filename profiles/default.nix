{
  home-manager,
  jovian,
  lanzaboote,
  nix-flatpak,
  plasma-manager,
  sops-nix,
  self,
  ...
}:

{
  apps = import ./apps;
  gaming = import ./gaming { inherit jovian nix-flatpak self; };
  nixos = import ./nixos { inherit sops-nix; };
  nixosDesktop = import ./nixos-desktop { inherit home-manager lanzaboote; };
  kde = import ./kde { inherit plasma-manager; };
  macos = import ./macos { inherit home-manager; };
  pi5 = import ./pi5;
  terminal = import ./terminal;
}
