{
  nixos =
    { pkgs, ... }:
    {
      networking.hostName = "pi5-server";
      boot.kernelPackages = pkgs.linuxPackages;
      system.stateVersion = "26.05";
      networking.firewall.enable = false;
      sops.defaultSopsFile = ../../secrets/pi5-server.yaml;

      my.nas.shares = [
        "Homelab"
        "Restic"
      ];
    };
}
