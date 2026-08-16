{
  nixos = {
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "nixos";
    system.stateVersion = "25.11";
  };
}
