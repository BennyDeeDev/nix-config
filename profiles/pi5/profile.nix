{
  nixos =
    { lib, ... }:
    {
      boot.initrd.availableKernelModules = {
        dw-hdmi = lib.mkForce false;
        dw-mipi-dsi = lib.mkForce false;
        pcie-rockchip-host = lib.mkForce false;
        phy-rockchip-pcie = lib.mkForce false;
        pwm-sun4i = lib.mkForce false;
        rockchip-rga = lib.mkForce false;
        rockchipdrm = lib.mkForce false;
        sun4i-drm = lib.mkForce false;
        sun8i-mixer = lib.mkForce false;
        tpm-crb = lib.mkForce false;
      };

      nix.settings.trusted-users = [ "benjamin" ];
    };
}
