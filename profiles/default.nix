{
  dgop,
  dms,
  dms-plugin-registry,
  home-manager,
  lanzaboote,
  ...
}:

{
  base = import ./base { inherit home-manager; };
  system = import ./system { inherit lanzaboote; };
  terminal = import ./terminal;
  graphical = import ./graphical {
    inherit dgop dms dms-plugin-registry;
  };
}
