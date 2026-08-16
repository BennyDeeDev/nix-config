inputs@{
  nixos-hardware,
  ...
}:

let
  host = import ./host.nix;
  profiles = import ../../profiles inputs;
in
{
  nixos = {
    imports = [
      profiles.base.nixos
      profiles.pi5.nixos
      nixos-hardware.nixosModules.raspberry-pi-5
      host.nixos
    ];
  };
}
