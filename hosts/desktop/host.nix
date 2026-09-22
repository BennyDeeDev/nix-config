{
  nixos = {
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "nixos";
    networking.interfaces.enp14s0.wakeOnLan.enable = true;
    system.stateVersion = "25.11";
  };
}
