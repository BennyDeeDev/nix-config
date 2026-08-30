inputs:

let
  profiles = import ../profiles inputs;
in
{
  nixos =
    { modulesPath, pkgs, ... }:
    {
      imports = [
        profiles.nixos.nixos
        profiles.pi5.nixos
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ];

      networking.hostName = "pi5-bootstrap";
      boot.kernelPackages = pkgs.linuxPackages;
      security.sudo.wheelNeedsPassword = false;
    };
}
