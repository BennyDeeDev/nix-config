{ ... }:

{
  imports = [
    ../../modules/pi5.nix
    ../../modules/nas.nix
    ../../modules/container-backup.nix
    ../../modules/services/gatus.nix
    ../../modules/services/ntfy-sh.nix
    ./home-assistant.nix
    ./otbr.nix
    ./matter-server.nix
  ];

  networking.hostName = "pi5-server";

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  host.nas = {
    shares = [
      "Homelab"
      "Restic"
    ];
  };

  host.gatus.endpoints = [
    {
      name = "Home Assistant";
      url = "http://127.0.0.1:8123";
      interval = "60s";
      conditions = [ "[STATUS] == 200" ];
    }
    {
      name = "OTBR REST";
      url = "http://127.0.0.1:8081";
      interval = "60s";
      conditions = [ "[STATUS] == 200" ];
    }
    {
      name = "Matter Server";
      url = "tcp://127.0.0.1:5580";
      interval = "60s";
    }
    # {
    #   name = "pi5-kiosk SSH";
    #   url = "tcp://pi5-kiosk.fritz.box:22";
    #   interval = "60s";
    # }
  ];

  sops.defaultSopsFile = ../../secrets/pi5-server.yaml;
}
