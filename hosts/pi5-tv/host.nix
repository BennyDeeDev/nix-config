inputs@{ ... }:

{
  nixos =
    { lib, pkgs, ... }:
    let
      rpiKernelFile = "${inputs.nixos-hardware.outPath}/raspberry-pi/common/kernel.nix";
      baseKernel = pkgs.callPackage rpiKernelFile {
        rpiVersion = 5;
      };
      rpiKernel4k = pkgs.callPackage rpiKernelFile {
        rpiVersion = 5;
        argsOverride = {
          structuredExtraConfig = baseKernel.structuredExtraConfig // {
            ARM64_4K_PAGES = lib.mkForce lib.kernel.yes;
            ARM64_16K_PAGES = lib.mkForce lib.kernel.no;
            ARM64_64K_PAGES = lib.mkForce lib.kernel.no;
          };
        };
      };
    in
    {
      networking.hostName = "pi5-tv";
      system.stateVersion = "26.05";
      boot.loader.generic-extlinux-compatible.useGenerationDeviceTree = false;
      boot.kernelParams = [ "video=HDMI-A-1:1920x1080@60D" ];
      boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor rpiKernel4k);
    };
}
