inputs@{
  home-manager,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
  nix = import ../../modules/nix.nix;
  homeManagerConfig = import ./home-manager.nix {
    inherit homeManagerModule profiles sops;
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
      homeManagerModule.darwin
      homeManagerConfig.darwin
      homebrew.darwin
      host.darwin
    ];
  };
}
