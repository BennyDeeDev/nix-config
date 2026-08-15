{
  dgop,
  dms,
  dms-plugin-registry,
  home-manager,
  lanzaboote,
  sops-nix,
  ...
}:

{
  base = import ./base { inherit home-manager sops-nix; };
  pi5 = import ./pi5;
  system = import ./system { inherit lanzaboote; };
  terminal = import ./terminal;
  graphical = import ./graphical {
    inherit dgop dms dms-plugin-registry;
  };
}
