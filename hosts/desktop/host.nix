{
  nixos = {
    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "nixos";
    system.stateVersion = "25.11";

    my.nas = {
      uid = 1000;
      gid = 100;
      shares = [
        "Homelab"
        "Benjamin"
        "Ludusavi"
        "Restic"
      ];
    };
  };
}
