inputs@{ ... }:

let
  androidTv = import ./android-tv;
  host = import ./host.nix;
  profiles = import ../../profiles inputs;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi5Graphical.nixos
      host.nixos
      androidTv.nixos
    ];
  };
}
