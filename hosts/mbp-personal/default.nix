inputs@{
  home-manager,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  myHomeManagerSystem = import ../../modules/home-manager.nix { inherit home-manager; };
  nix = import ../../modules/nix.nix;
  myHomeManager = import ./home-manager.nix {
    inherit myHomeManagerSystem profiles sops;
  };
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
      myHomeManagerSystem.darwin
      myHomeManager.darwin
      homebrew.darwin
      host.darwin
    ];
  };
}
