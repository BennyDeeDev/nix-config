{
  homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.steam-rom-manager ];
    };
}
