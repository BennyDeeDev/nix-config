{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/otbr 0755 root root -"
  ];

  virtualisation.oci-containers.containers.otbr = {
    image = "docker.io/openthread/border-router:latest";
    extraOptions = [
      "--network=host"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
      "--device=/dev/serial/by-id/usb-Nabu_Casa_ZBT-2_94A990D189AC-if00:/dev/ttyACM0"
      "--device=/dev/net/tun:/dev/net/tun"
    ];
    environment = {
      TZ = "Europe/Berlin";
      OT_RCP_DEVICE = "spinel+hdlc+uart:///dev/ttyACM0?uart-baudrate=460800";
      OT_INFRA_IF = "end0";
      OT_THREAD_IF = "wpan0";
      OT_REST_LISTEN_ADDR = "0.0.0.0";
      OT_REST_LISTEN_PORT = "8081";
    };
    volumes = [
      "/var/lib/otbr:/data:rw"
    ];
  };

  host.containerBackups.otbr = {
    repository = "/mnt/nas/restic/otbr-restic";
    paths = [ "/var/lib/otbr" ];
    services = [ "podman-otbr.service" ];
    mountPoint = "/mnt/nas/restic";
  };
}