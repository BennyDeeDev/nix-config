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
  };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bluetui ];
    };
}
