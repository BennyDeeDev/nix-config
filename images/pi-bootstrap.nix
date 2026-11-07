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
        profiles.pi.nixos
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ];

      networking.hostName = "pi";

      # Passwordless wheel only on the bootstrap image
      security.sudo.wheelNeedsPassword = false;
    };
}
