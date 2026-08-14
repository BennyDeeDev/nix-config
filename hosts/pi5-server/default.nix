{
  inputs,
  moduleSet,
  systemProfile,
  ...
}:

{
  imports = [
    systemProfile.nixos
    moduleSet.sops.nixos
    moduleSet.pi5.nixos
    moduleSet.nas.nixos
    moduleSet.container-backup.nixos
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
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
