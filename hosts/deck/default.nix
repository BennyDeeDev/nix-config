inputs@{
  home-manager,
  jovian,
  sops-nix,
  ...
}:

let
  homeManagerModule = import ../../modules/home-manager.nix { inherit home-manager; };
  nasModule = import ../../modules/nas.nix;
  nixModule = import ../../modules/nix.nix;
  profiles = import ../../profiles inputs;
  sopsModule = import ../../modules/sops.nix { inherit sops-nix; };
  host = import ./host.nix { inherit inputs; };
  sdgyrodsu = import ./sdgyrodsu.nix { inherit jovian; };
  steamRomManager = import ./steam-rom-manager.nix;
in
{
  homeManager = {
    imports = [
      homeManagerModule.homeManager
      nasModule.homeManager
      nixModule.homeManager
      sopsModule.homeManager
      profiles.apps.homeManager
      profiles.gaming.homeManager
      profiles.kde.homeManager
      profiles.terminal.homeManager
      host.homeManager
      sdgyrodsu.homeManager
      steamRomManager.homeManager
    ];
  };
}
