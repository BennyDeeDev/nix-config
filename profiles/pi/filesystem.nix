{
  nixos =
    { config, lib, ... }:
    {
      fileSystems."/" = {
        device = lib.mkDefault (
          if config.my.pi.bootMedium == "nvme" then
            "/dev/disk/by-label/NIXOS_NVME"
          else
            "/dev/disk/by-label/NIXOS_SD"
        );
        fsType = "ext4";
      };
    };
}
