{
  nixos = {
    hardware = {
      cpu.amd.updateMicrocode = true;
      enableRedistributableFirmware = true;
      amdgpu.initrd.enable = true;
    };

    fileSystems."/var/log".neededForBoot = true;
  };
}
