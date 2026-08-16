{
  dgop,
  dms,
  dms-plugin-registry,
  lanzaboote,
  sops-nix,
  ...
}:

{
  nixos = import ./nixos { inherit sops-nix; };
  desktop = import ./desktop {
    inherit dgop dms dms-plugin-registry;
    inherit lanzaboote;
  };
  macos = import ./macos;
  pi5 = import ./pi5;
  terminal = import ./terminal;
}
