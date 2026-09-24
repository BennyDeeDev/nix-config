{
  jovian,
  nix-flatpak,
  self,
}:

let
  bottles = import ./bottles.nix;
  flatpak = import ./flatpak.nix { inherit nix-flatpak; };
  lsfg = import ./lsfg.nix { inherit self; };
  ludusavi = import ./ludusavi.nix;
  profile = import ./profile.nix;
  steam = import ./steam.nix { inherit jovian; };
in
{
  nixos = {
    imports = [
      flatpak.nixos
      steam.nixos
    ];
  };

  homeManager = {
    imports = [
      bottles.homeManager
      flatpak.homeManager
      lsfg.homeManager
      ludusavi.homeManager
      profile.homeManager
      steam.homeManager
    ];
  };
}
