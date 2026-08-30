{
  nixos =
    { ... }:
    {
      networking.hostName = "pi5-tv";
      system.stateVersion = "26.05";
      boot.kernelParams = [ "video=HDMI-A-1:1920x1080@60D" ];
    };
}
