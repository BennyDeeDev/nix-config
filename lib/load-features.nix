{ lib }:

{
  directory,
  args,
  exclude ? [ "default.nix" ],
}:

let
  entries = builtins.readDir directory;
  featureFiles = lib.filter (
    name: entries.${name} == "regular" && lib.hasSuffix ".nix" name && !(builtins.elem name exclude)
  ) (builtins.attrNames entries);
  features = map (name: import (directory + "/${name}") args) featureFiles;
  facetModules =
    facet: lib.filter (module: module != null) (map (feature: feature.${facet} or null) features);
  facet =
    name:
    let
      imports = facetModules name;
    in
    lib.optionalAttrs (imports != [ ]) {
      ${name} = { inherit imports; };
    };
in
facet "nixos" // facet "homeManager" // facet "darwin"
