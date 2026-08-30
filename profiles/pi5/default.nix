let
  filesystem = import ./filesystem.nix;
  graphical = import ./graphical.nix;
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
    ];
  };

  graphical = graphical.nixos;
}
