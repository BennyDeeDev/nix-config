{
  myHomeManagerSystem,
  profiles,
  sops,
}:

let
  apps = import ../../modules/apps.nix;
  ghostty = import ../../modules/ghostty.nix;
  vscode = import ../../modules/vscode.nix;
in

{
  darwin = {
    home-manager = {
      extraSpecialArgs = {
        nixConfig = "/Users/benjaminderksen/Repos/nix-config";
        flakeHost = "mbp-personal";
      };
      users.benjaminderksen = {
        imports = [
          profiles.terminal.homeManager
          profiles.macos.homeManager
          apps.homeManager
          ghostty.homeManager
          myHomeManagerSystem.homeManager
          vscode.homeManager
          sops.homeManager
        ];

        home.stateVersion = "26.05";
        my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-19TEYVQ5ZLFFEFYSGZHTZ3";
      };
    };
  };
}
