{
  nixos =
    { pkgs, ... }:
    {
      services.udev.packages = [ pkgs.asdbctl ];
    };

  homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [ pkgs.asdbctl ];
    };
}
