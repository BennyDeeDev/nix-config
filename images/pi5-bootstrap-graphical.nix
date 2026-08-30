inputs@{ nixos-hardware, ... }:

let
  profiles = import ../profiles inputs;
in
{
  nixos =
    { lib, modulesPath, ... }:
    {
      imports = [
        profiles.nixos.nixos
        profiles.pi5.nixos
        profiles.pi5.graphical
        nixos-hardware.nixosModules.raspberry-pi-5
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ];

      networking.hostName = "pi5-bootstrap-graphical";
      security.sudo.wheelNeedsPassword = false;

      boot.supportedFilesystems.zfs = lib.mkForce false;
      boot.initrd.supportedFilesystems.zfs = lib.mkForce false;

      sdImage.firmwareSize = 64;
      hardware.raspberry-pi.firmware.uboot.enable = true;
    };
}
