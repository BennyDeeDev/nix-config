inputs:

let
  profiles = import ../profiles inputs;
in
{
  nixos =
    { modulesPath, ... }:
    {
      imports = [
        profiles.nixos.nixos
        profiles.pi5.nixos
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ];

      networking.hostName = "pi5-bootstrap";
      system.stateVersion = "26.05";
      security.sudo.wheelNeedsPassword = false;
    };
}
