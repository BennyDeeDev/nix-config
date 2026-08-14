{ ... }:

{
  nixos = { ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
        Policy.AutoEnable = true;
      };
    };

    services.blueman.enable = true;
  };

  homeManager = { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [ pkgs.bluetui ];
    };
}
