inputs:

let
  profiles = import ../profiles inputs;
in
{
  nixos =
    { pkgs, ... }:
    {
      imports = [ profiles.pi5Image.nixos ];

      boot.kernelPackages = pkgs.linuxPackages;
    };
}
