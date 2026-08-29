{
  nixos =
    { pkgs, ... }:
    {
      boot.loader.generic-extlinux-compatible.enable = true;
      boot.loader.timeout = 0;

      environment.systemPackages = with pkgs; [
        evtest
        htop
        usbutils
        v4l-utils
      ];

      networking.useDHCP = true;

      security.sudo.wheelNeedsPassword = false;
    };
}
