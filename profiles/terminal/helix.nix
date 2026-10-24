{ helixFlake }:
let
  helixPerlOverlay = import ../../overlays/helix-perl.nix;
in
{
  homeManager =
    { pkgs, ... }:
    {
      programs.helix = {
        enable = true;
        package = helixFlake.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
          grammarOverlays = [ helixPerlOverlay ];
        };

        settings = {
          theme = {
            dark = "catppuccin_mocha";
            light = "catppuccin_latte";
          };

          editor = {
            scrolloff = 8;
          };
        };

        languages.language =
          map
            (name: {
              inherit name;
              auto-format = true;
            })
            [
              "nix"
              "markdown"
              "bash"
              "toml"
            ];

      };
    };
}
