inputs@{ ... }:

let
  androidTv = import ./android-tv;
  host = import ./host.nix inputs;
  profiles = import ../../profiles inputs;
in
{
  nixos = {
    imports = [
      profiles.nixos.nixos
      profiles.pi5.nixos
      host.nixos
      androidTv.nixos
    ];
  };
}
