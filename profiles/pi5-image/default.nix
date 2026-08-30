{
  nixos-hardware,
  sops-nix,
}:

let
  nixos = import ../nixos { inherit sops-nix; };
  pi5 = import ../pi5 { inherit nixos-hardware; };
in
{
  nixos =
    { modulesPath, ... }:
    {
      imports = [
        nixos.nixos
        pi5.nixos
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ];

      hardware.raspberry-pi.firmware.uboot.enable = true;
      networking.hostName = "pi5-bootstrap";
      security.sudo.wheelNeedsPassword = false;
      system.stateVersion = "26.05";
    };
}
