{ ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/matter-server 0755 1000 1000 -"
  ];

  virtualisation.oci-containers.containers.matter-server = {
    image = "ghcr.io/matter-js/matterjs-server:stable";
    extraOptions = [
      "--network=host"
      "--security-opt=apparmor=unconfined"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
    ];
    environment = {
      TZ = "Europe/Berlin";
      PRIMARY_INTERFACE = "end0";
    };
    volumes = [
      "/var/lib/matter-server:/data:rw"
    ];
  };

  host.containerBackups.matter = {
    repository = "/mnt/nas/restic/matter-restic";
    paths = [ "/var/lib/matter-server" ];
    services = [ "podman-matter-server.service" ];
    mountPoint = "/mnt/nas/restic";
  };
}