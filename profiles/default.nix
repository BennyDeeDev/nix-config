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
  darwin = import ./darwin;
  nixos = import ./nixos {
    inherit dgop dms dms-plugin-registry;
    inherit lanzaboote;
  };
  pi5 = import ./pi5;
  shared = import ./shared {
    inherit dgop dms dms-plugin-registry;
  };
  terminal = import ./terminal;
}
