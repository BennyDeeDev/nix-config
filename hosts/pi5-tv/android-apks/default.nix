{ pkgs }:
{
  nuvio = import ./nuvio.nix { inherit pkgs; };
  retroarch = import ./retroarch.nix { inherit pkgs; };
  smarttube = import ./smarttube.nix { inherit pkgs; };
  stremio = import ./stremio.nix { inherit pkgs; };
}
