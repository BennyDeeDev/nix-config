{
  profiles,
  sops,
}:

{
  darwin = {
    home-manager = {
      extraSpecialArgs = {
        dotfiles = "/Users/benjaminderksen/Repos/dotfiles";
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
