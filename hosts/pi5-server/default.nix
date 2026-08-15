{ ... }:

{
  imports = [
    ./home-assistant.nix
  ];

  networking.hostName = "pi5-server";

  # Firewall disabled temporarily
  networking.firewall.enable = false;

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  host.nas = {
    shares = [
      "Homelab"
      "Restic"
    ];
  };

  sops.defaultSopsFile = ../../secrets/pi5-server.yaml;
}
