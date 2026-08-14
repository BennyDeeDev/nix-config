{ inputs, repoRoot, ... }:

{
  nixos = { ... }: {
    services.printing.enable = true;
  };
}
