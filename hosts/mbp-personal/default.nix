inputs@{
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  nixModule = import ../../modules/nix.nix;
  homeManagerConfig = import ./home-manager.nix {
    inherit profiles sopsModule;
  };
  host = import ./host.nix;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
  homebrew = import ./homebrew.nix;
  users = import ./users.nix;
in
{
  darwin = {
    imports = [
      nixModule.darwin
      profiles.macos.darwin
      users.darwin
      homeManagerConfig.darwin
      homebrew.darwin
      host.darwin
    ];
  };
}
