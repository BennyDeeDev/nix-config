{ steamdexFlake }:

let
  steamdexModule = import ../../modules/steamdex.nix;
in
{
  homeManager =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [ steamdexModule.homeManager ];

      my.steamdex = {
        enable = true;
        package = steamdexFlake.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings.steam = {
          directory = "${config.home.homeDirectory}/.local/share/Steam";
          user_data_id = "127725003";
        };
      };
    };
}
