{
  nixos =
    { pkgs, ... }:
    {
      services.udev.packages = [ pkgs.asdbctl ];
    };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.asdbctl ];
    };
}
