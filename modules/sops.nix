{ sops-nix }:

{
  nixos =
    { config, lib, ... }:
    {
      imports = [ sops-nix.nixosModules.sops ];

      options.my.sops.smartcard.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable PC/SC smartcard support for SOPS.";
      };

      config = {
        users.mutableUsers = false;

        sops.age = {
          keyFile = "/var/lib/sops-nix/key.txt";
          generateKey = true;
          sshKeyPaths = [ ];
        };

        services.pcscd.enable = config.my.sops.smartcard.enable;
      };
    };

  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ sops-nix.homeManagerModules.sops ];

      options.my.sops.yubikeyIdentity = lib.mkOption {
        type = lib.types.str;
        description = "age-plugin-yubikey identity pointer.";
      };

      config = {
        home.packages = with pkgs; [
          age
          age-plugin-yubikey
          sops
          yubikey-manager
        ];

        sops.age = {
          keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
          generateKey = true;
        };

        xdg.configFile."sops/age/identity.txt" = {
          text = config.my.sops.yubikeyIdentity;
        };

        home.sessionVariables = {
          SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/identity.txt";
        };
      };
    };
}
