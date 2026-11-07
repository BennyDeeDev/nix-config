{
  nixos = {
    services.ntopng = {
      enable = true;
      interfaces = [
        "end0"
        "enP1p3s0"
        "enP1p4s0"
      ];
      httpPort = 3000;
    };

    networking.firewall.interfaces.enP1p4s0.allowedTCPPorts = [ 3000 ];
  };
}
