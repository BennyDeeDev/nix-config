{
  nixos =
    { ... }:
    {
      programs = {
        fuse = {
          enable = true;
        };
        nix-ld = {
          enable = true;
        };
      };
      services.envfs.enable = true;
    };
}
