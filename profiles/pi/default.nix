let
  boot = import ./boot.nix;
  filesystem = import ./filesystem.nix;
  openssh = import ./openssh.nix;
  profile = import ./profile.nix;
  users = import ./users.nix;
in
{
  nixos = {
    imports = [
      boot.nixos
      filesystem.nixos
      openssh.nixos
      profile.nixos
      users.nixos
    ];
  };
}
