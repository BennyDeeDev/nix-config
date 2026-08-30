{ nixos-hardware }:

let
  filesystem = import ./filesystem.nix;
  openssh = import ./openssh.nix;
  profile = import ./profile.nix;
  users = import ./users.nix;
in
{
  nixos = {
    imports = [
      filesystem.nixos
      openssh.nixos
      profile.nixos
      users.nixos
      nixos-hardware.nixosModules.raspberry-pi-5
    ];
  };
}
