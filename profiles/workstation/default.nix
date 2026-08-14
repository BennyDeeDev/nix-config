{ lib, systemProfile, ... }@args:

let
  features = (import ../../lib/load-features.nix { inherit lib; }) {
    directory = ./.;
    inherit args;
  };
  profileModules = {
    homeManager = {
      programs.home-manager.enable = true;
    };
  };
  compose = name:
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
