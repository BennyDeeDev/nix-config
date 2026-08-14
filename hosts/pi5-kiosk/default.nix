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
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
  ];

  networking.hostName = "pi5-kiosk";

  # TODO: kiosk display / browser config
}
