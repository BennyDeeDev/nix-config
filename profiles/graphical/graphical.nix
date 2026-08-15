{
  nixos =
    { pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      programs.dconf.enable = true;
      security.polkit.enable = true;
    };
}