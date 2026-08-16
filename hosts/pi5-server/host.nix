{
  nixos = {
    networking.hostName = "pi5-server";
    networking.firewall.enable = false;
    sops.defaultSopsFile = ../../secrets/pi5-server.yaml;

    my.nas.shares = [
      "Homelab"
      "Restic"
    ];
  };
}
