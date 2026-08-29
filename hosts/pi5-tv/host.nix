{
  nixos =
    { config, lib, pkgs, ... }:
    {
      networking.hostName = "pi5-tv";

      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      boot.kernelModules = [ "v3d" ];
      boot.kernelParams = [ "video=HDMI-A-1:1920x1080@60D" ];

      fileSystems."/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
      };

      hardware.raspberry-pi.configtxt.settings.all.dtparam = [ "audio=on" ];
      hardware.raspberry-pi.firmware.uboot.enable = true;

      system.activationScripts.raspberry-pi-configtxt = lib.stringAfter [ "specialfs" ] ''
        if mountpoint -q /boot/firmware; then
          ${lib.getExe' pkgs.coreutils "install"} -m 0644 \
            ${config.hardware.raspberry-pi.configtxt.file} /boot/firmware/config.txt
        else
          echo "rpi-config: /boot/firmware is not mounted, skipping config.txt install" >&2
        fi
      '';
    };
}
