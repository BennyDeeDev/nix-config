{
  nixos =
    { lib, pkgs, ... }:
    {
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      boot.kernelModules = [ "v3d" ];
      boot.kernelParams = [ "video=HDMI-A-1:1920x1080@60D" ];

      hardware.raspberry-pi.configtxt.settings = {
        all.dtparam = [ "audio=on" ];
      };
    };
}
