{
  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.steamdex;
      settingsFormat = pkgs.formats.json { };
    in
    {
      options.my.steamdex = {
        enable = lib.mkEnableOption "Steamdex";

        package = lib.mkOption {
          type = lib.types.package;
          description = "The Steamdex package to use.";
        };

        settings = lib.mkOption {
          inherit (settingsFormat) type;
          default = { };
          description = "Steamdex settings written to config.json.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];

        xdg.configFile."steamdex/config.json".source =
          settingsFormat.generate "steamdex-config.json" cfg.settings;

        sops.secrets."steamgriddb-api-key".sopsFile = ../secrets/common.yaml;

        sops.templates."steamdex-secrets.json" = {
          path = "${config.xdg.configHome}/steamdex/secrets.json";
          content = builtins.toJSON {
            steamgriddb_api_key = config.sops.placeholder."steamgriddb-api-key";
          };
        };
      };
    };
}
