{
  nixos =
    { ... }:
    {
      services.gnome.gnome-keyring.enable = true;
    };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.libsecret ];
    };
}
