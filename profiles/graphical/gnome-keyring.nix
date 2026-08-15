{
  nixos =
    { ... }:
    {
      services.gnome.gnome-keyring.enable = true;
    };

  homeManager =
    { lib, pkgs, ... }:
    {
      home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.libsecret ];
    };
}
