{
  nixos = {
    networking.hostName = "pi5-router";

    boot.loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };
}
