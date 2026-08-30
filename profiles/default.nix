{
  dank-greeter,
  dms,
  dms-plugin-registry,
  home-manager,
  lanzaboote,
  nixos-hardware,
  sops-nix,
  ...
}:

{
  nixos = import ./nixos { inherit sops-nix; };
  desktop = import ./desktop {
    inherit
      dank-greeter
      dms
      dms-plugin-registry
      home-manager
      ;
    inherit lanzaboote;
  };
  macos = import ./macos { inherit home-manager; };
  pi5 = import ./pi5 { inherit nixos-hardware; };
  pi5Image = import ./pi5-image { inherit nixos-hardware sops-nix; };
  terminal = import ./terminal;
}
