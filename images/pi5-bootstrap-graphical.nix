inputs@{ ... }:

let
  profiles = import ../profiles inputs;
in
{
  nixos =
    { lib, modulesPath, ... }:
    {
      imports = [
        profiles.nixos.nixos
        profiles.pi5Graphical.nixos
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ];

      networking.hostName = "pi5-bootstrap-graphical";
      security.sudo.wheelNeedsPassword = false;

      boot.supportedFilesystems.zfs = lib.mkForce false;
      boot.initrd.supportedFilesystems.zfs = lib.mkForce false;

      hardware.raspberry-pi.firmware.uboot.enable = true;
    };
}
