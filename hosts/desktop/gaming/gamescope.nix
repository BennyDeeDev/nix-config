{ ... }:

{
  nixos = { ... }:
    {
      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };
    };
}
