{
  nixos = { ... }: {
    networking.networkmanager.enable = true;
  };

  homeManager =
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = [ pkgs.impala ];
    };
}
