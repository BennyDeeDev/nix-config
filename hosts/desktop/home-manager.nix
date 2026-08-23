{
  gaming,
  profiles,
  sopsModule,
}:

{
  nixos = {
    home-manager = {
      extraSpecialArgs = {
        nixConfig = "/home/benjamin/Repos/nix-config";
        flakeHost = "desktop";
      };
      users.benjamin =
        { ... }:
        {
          imports = [
            profiles.desktop.homeManager
            profiles.terminal.homeManager
            sopsModule.homeManager
            gaming.homeManager
          ];

          sops.defaultSopsFile = ../../secrets/desktop.yaml;
          my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
          home = {
            username = "benjamin";
            homeDirectory = "/home/benjamin";
            stateVersion = "25.11";
          };
        };
    };
  };
}
