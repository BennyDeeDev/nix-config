{ ... }@args:

{
  sops = import ./sops.nix args;
  nas = import ./nas.nix args;
  container-backup = import ./container-backup.nix args;
  pi5 = import ./pi5.nix args;
}
