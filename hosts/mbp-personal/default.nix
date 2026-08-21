inputs@{
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  homeManagerConfig = import ./home-manager.nix {
    inherit profiles sopsModule;
  };
  host = import ./host.nix;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
  homebrew = import ./homebrew.nix;
in
{
  darwin = {
    imports = [
      profiles.macos.darwin
      homeManagerConfig.darwin
      homebrew.darwin
      host.darwin
    ];
  };
}
