{
  profiles,
  sops,
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
          profiles.shared.homeManager
          profiles.darwin.homeManager
          sops.homeManager
        ];

        home.stateVersion = "26.05";
        my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-19TEYVQ5ZLFFEFYSGZHTZ3";
      };
    };
  };
}
