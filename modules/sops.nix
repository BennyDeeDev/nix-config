{ inputs, ... }:

{
  nixos =
    { config, lib, ... }:
    let
      cfg = config.dotfiles.sops;
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      options.dotfiles.sops.smartcard.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable PC/SC smartcard support for SOPS.";
      };

      config = {
        users.mutableUsers = false;

        sops.age.keyFile = "/var/lib/sops-nix/key.txt";
        sops.age.generateKey = true;
        sops.age.sshKeyPaths = [ ];

        services.pcscd.enable = cfg.smartcard.enable;
      };
    };

  homeManager =
    { config, lib, pkgs, ... }:
    let
      cfg = config.dotfiles.sops;
      identityFile = "${config.xdg.configHome}/sops/age/identity.txt";
    in
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      options.dotfiles.sops.yubikeyIdentity = lib.mkOption {
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

        sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        sops.age.generateKey = true;

        home.file."${config.xdg.configHome}/sops/age/identity.txt" = {
          text = cfg.yubikeyIdentity;
        };

        home.sessionVariables = {
          SOPS_AGE_KEY_FILE = identityFile;
        };
      };
    };
}
