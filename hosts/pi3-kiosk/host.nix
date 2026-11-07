{
  nixos = {
    networking.hostName = "pi3-kiosk";
    networking.firewall.enable = true;

    boot.loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };
}
