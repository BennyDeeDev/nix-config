let
  filesystem = import ./filesystem.nix;
  kernel = import ./kernel.nix;
  nix = import ./nix.nix;
  openssh = import ./openssh.nix;
  host = import ./host.nix;
  users = import ./users.nix;
in
{
  nixos = {
    imports = [
      filesystem.nixos
      kernel.nixos
      nix.nixos
      openssh.nixos
      host.nixos
      users.nixos
    ];
  };
}
