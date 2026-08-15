{ ... }:

{
  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    amdgpu.initrd.enable = true;
  };

  fileSystems = {
    "/mnt/bazzite" = {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S7HDNJ0Y413952T-part3";
      fsType = "btrfs";
      options = [
        "rw"
        "subvol=/home"
        "relatime"
        "ssd"
        "discard=async"
        "space_cache=v2"
        "nofail"
      ];
    };
    "/var/log".neededForBoot = true;
  };
}
