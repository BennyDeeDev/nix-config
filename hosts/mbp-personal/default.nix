inputs@{
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  homeManager = import ./home-manager.nix { inherit profiles sops; };
  host = import ./host.nix;
  sops = import ../../modules/sops.nix { inherit sops-nix; };
  homebrew = import ./homebrew.nix;
  users = import ./users.nix;
in
{
  darwin = {
    imports = [
      profiles.base.darwin
      profiles.darwin.darwin
      users.darwin
      homeManager.darwin
      homebrew.darwin
      host.darwin
    ];
  };
}
