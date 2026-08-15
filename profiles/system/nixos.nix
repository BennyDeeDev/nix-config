{
  nixos =
    { ... }:
    {
      programs.fuse.enable = true;
      services.envfs.enable = true;
      programs.nix-ld.enable = true;
    };
}