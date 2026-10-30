{
  nixos = {
    networking.hostName = "pi5-server";
    boot.loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
    sops.defaultSopsFile = ../../secrets/pi5-server.yaml;

    my.nas.shares = [
      "Homelab"
      "Restic"
    ];
  };
}
