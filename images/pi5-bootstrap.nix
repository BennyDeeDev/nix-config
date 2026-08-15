{
  home-manager,
  sops-nix,
  ...
}:

let
  systemProfile = import ../profiles/system { inherit home-manager; };
  sops = import ../modules/sops.nix { inherit sops-nix; };
  pi5 = import ../modules/pi5.nix { };
in
{ modulesPath, ... }:

{
  imports = [
    systemProfile.nixos
    sops.nixos
    pi5.nixos
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "pi5";

  # Passwordless wheel only on the bootstrap image
  security.sudo.wheelNeedsPassword = false;
}
