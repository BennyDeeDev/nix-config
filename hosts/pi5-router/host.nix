{
  nixos = {
    networking.hostName = "pi5-router";
    # The ZP595's RTL8125B NICs use r8169, which requests rtl_nic/rtl8125b-2.fw.
    # Without linux-firmware, both NICs logged "Unable to load firmware" at boot.
    hardware.enableRedistributableFirmware = true;

    boot.loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };
}
