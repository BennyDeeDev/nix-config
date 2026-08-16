{
  nixos = { ... }: {
    networking.networkmanager.enable = true;
  };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.impala ];
    };
}
