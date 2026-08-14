{
  moduleSet,
  modulesPath,
  systemProfile,
  ...
}:

{
  imports = [
    systemProfile.nixos
    moduleSet.sops.nixos
    moduleSet.pi5.nixos
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "pi5";

  # Passwordless wheel only on the bootstrap image
  security.sudo.wheelNeedsPassword = false;
}
