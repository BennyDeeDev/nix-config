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

      sops.secrets."steamgriddb-api-key".sopsFile = ../../secrets/shared-desktop.yaml;

      sops.templates."steamdex-secrets.json" = {
        path = "${config.xdg.configHome}/steamdex/secrets.json";
        content = builtins.toJSON {
          steamgriddb_api_key = config.sops.placeholder."steamgriddb-api-key";
        };
      };

      my.steamdex = {
        enable = true;
        package = steamdexFlake.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings = {
          steam = {
            directory = "${config.home.homeDirectory}/.local/share/Steam";
            user_data_id = "127725003";
          };
          secrets_file = "${config.xdg.configHome}/steamdex/secrets.json";
        };
      };
    };
}
