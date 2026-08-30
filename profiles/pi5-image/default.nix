{
  nixos-hardware,
  sops-nix,
}:

let
  nixos = import ../nixos { inherit sops-nix; };
  pi5 = import ../pi5 { inherit nixos-hardware; };
in
{
  nixos =
    { lib, modulesPath, ... }:
    {
      imports = [
        nixos.nixos
        pi5.nixos
        "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
      ];

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

      hardware.raspberry-pi.firmware.uboot.enable = true;
      networking.hostName = "pi5-bootstrap";
      security.sudo.wheelNeedsPassword = false;
      system.stateVersion = "26.05";
    };
}
