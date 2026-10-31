{
  nixos = {
    networking.hostName = "pi5-kiosk";
    networking.firewall.enable = true;

    boot.loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };
}
