inputs@{
  home-manager,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  myHomeManager = import ../../modules/home-manager.nix { inherit home-manager; };
  nix = import ../../modules/nix.nix;
  homeManager = import ./home-manager.nix { inherit profiles sops; };
  host = import ./host.nix;
  sops = import ../../modules/sops.nix { inherit sops-nix; };
  homebrew = import ./homebrew.nix;
  users = import ./users.nix;
in
{
  darwin = {
    imports = [
      nix.darwin
      profiles.macos.darwin
      users.darwin
      myHomeManager.darwin
      homeManager.darwin
      homebrew.darwin
      host.darwin
    ];
  };
}
