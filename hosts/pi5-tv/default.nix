inputs@{
  nixos-hardware,
  ...
}:

let
  androidTv = import ./android-tv;
  base = import ./base.nix;
  host = import ./host.nix;
  profiles = import ../../profiles inputs;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi5.nixos
      profiles.pi5.graphical
      base.nixos
      nixos-hardware.nixosModules.raspberry-pi-5
      host.nixos
      androidTv.nixos
    ];
  };
}
