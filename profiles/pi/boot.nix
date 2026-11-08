{
  nixos =
    { config, lib, ... }:
    let
      ubootRpiArm64 = import ../../overlays/uboot-rpi-arm64.nix;
    in
    {
      options.my.pi.bootMedium = lib.mkOption {
        type = lib.types.enum [
          "sd"
          "nvme"
        ];
        default = "sd";
        description = "Pi boot medium; NVMe enables the patched Pi 5 U-Boot and initrd drivers.";
      };

      config = lib.mkIf (config.my.pi.bootMedium == "nvme") {
        boot = {
          initrd.availableKernelModules = [
            "nvme"
            "pcie-brcmstb"
          ];
          loader = {
            generic-extlinux-compatible.enable = true;
            grub.enable = false;
          };
        };

        nixpkgs.overlays = [ ubootRpiArm64 ];
      };
    };
}
