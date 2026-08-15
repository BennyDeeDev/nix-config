{ lib, systemProfile, ... }@args:

let
  features = (import ../../lib/load-features.nix { inherit lib; }) {
    directory = ./.;
    inherit args;
  };
  profileModules = {
    nixos =
      { pkgs, ... }:
      {
        nixpkgs.config.allowUnfree = true;
        nix.settings.auto-optimise-store = true;
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };

        programs.fuse.enable = true;
        programs.vim.defaultEditor = true;
        zramSwap.enable = true;
        services.envfs.enable = true;
        programs.nix-ld.enable = true;

        environment.systemPackages = [ pkgs.gcc ];
        security.sudo.extraConfig = ''
          Defaults timestamp_type=tty,timestamp_timeout=-1
        '';
      };
    homeManager = {
      programs.home-manager.enable = true;
    };
  };
  compose =
    name:
    let
      imports =
        lib.optional (builtins.hasAttr name systemProfile) systemProfile.${name}
        ++ lib.optional (builtins.hasAttr name profileModules) profileModules.${name}
        ++ lib.optional (builtins.hasAttr name features) features.${name};
    in
    lib.optionalAttrs (imports != [ ]) {
      ${name} = { inherit imports; };
    };
in
compose "nixos" // compose "homeManager" // compose "darwin"
