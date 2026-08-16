{
  profiles,
  sopsModule,
}:

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
          sopsModule.homeManager
        ];

        home.stateVersion = "26.05";
        my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-19TEYVQ5ZLFFEFYSGZHTZ3";
      };
    };
  };
}
