{
  nixos = {
    services.openthread-border-router = {
      enable = true;
      openFirewall = true;
      backboneInterfaces = [ "end0" ];
      interfaceName = "wpan0";
      radio = {
        device = "/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_94A990D189AC-if00";
        baudRate = 460800;
      };
      rest.listenAddress = "0.0.0.0";
      rest.listenPort = 8081;
    };

    my.restic.otbr = {
      repository = "/mnt/nas/restic/otbr-restic";
      path = "/var/lib/thread";
      service = "otbr-agent.service";
      mountPoint = "/mnt/nas/restic";
    };
  };
}
