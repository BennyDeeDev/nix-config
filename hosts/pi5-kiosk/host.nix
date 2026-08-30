{
  nixos =
    { pkgs, ... }:
    {
      networking.hostName = "pi5-kiosk";
      system.stateVersion = "26.05";
    };
}
