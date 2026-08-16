inputs:

let
  profiles = import ../profiles inputs;
in
{
  nixos =
    { modulesPath, ... }:
    {
      imports = [
        profiles.base.nixos
        profiles.pi5.nixos
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ];

      networking.hostName = "pi5";

      # Passwordless wheel only on the bootstrap image
      security.sudo.wheelNeedsPassword = false;
    };
}
