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
  nixos = import ./nixos { inherit sops-nix; };
  desktop = import ./desktop {
    inherit
      dgop
      dms
      dms-plugin-registry
      home-manager
      ;
    inherit lanzaboote;
  };
  macos = import ./macos { inherit home-manager; };
  pi5 = import ./pi5;
  terminal = import ./terminal;
}
