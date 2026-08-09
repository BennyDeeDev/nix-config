{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/homeassistant 0755 root root -"
  ];

  virtualisation.oci-containers.containers.homeassistant = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    extraOptions = [
      "--network=host"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
    ];
    environment.TZ = "Europe/Berlin";
    volumes = [
      "/var/lib/homeassistant:/config:rw"
    ];
  };

  host.containerBackups.ha = {
    repository = "/mnt/nas/restic/ha-restic";
    paths = [ "/var/lib/homeassistant" ];
    services = [ "podman-homeassistant.service" ];
    mountPoint = "/mnt/nas/restic";
  };
}