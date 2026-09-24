{
  nixos =
    { config, ... }:
    {
      nixpkgs.hostPlatform = "x86_64-linux";
      networking.hostName = "nixos";
      networking.interfaces.enp14s0.wakeOnLan.enable = true;
      system.stateVersion = "25.11";

      boot = {
        extraModulePackages = [ config.boot.kernelPackages.r8125 ];
        blacklistedKernelModules = [ "r8169" ];
        kernelModules = [ "r8125" ];
        extraModprobeConfig = ''
          options r8125 s5wol=1 aspm=0
        '';
      };

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
