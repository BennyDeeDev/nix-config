{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.steam-rom-manager;

  jsonFormat = pkgs.formats.json { };

  userSettingsFile =
    if cfg.userSettingsFile != null then
      cfg.userSettingsFile
    else
      jsonFormat.generate "userSettings.json" cfg.userSettings;

  userConfigurationsFile =
    if cfg.userConfigurationsFile != null then
      cfg.userConfigurationsFile
    else
      jsonFormat.generate "userConfigurations.json" cfg.userConfigurations;
in
{
  meta.maintainers = [ ];

  options.programs.steam-rom-manager = {
    enable = lib.mkEnableOption "Steam ROM Manager";

    package = lib.mkPackageOption pkgs "steam-rom-manager" {
      nullable = true;
    };

    userSettings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        environmentVariables = {
          steamDirectory = "/home/user/.local/share/Steam";
          userAccounts = [ ];
        };
      };
      description = ''
        Configuration written to Steam ROM Manager's
        {file}`userSettings.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.userSettingsFile`.
      '';
    };

    userSettingsFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = ''
        Path to an existing Steam ROM Manager
        {file}`userSettings.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.userSettings`.
      '';
    };

    userConfigurations = lib.mkOption {
      inherit (jsonFormat) type;
      default = [ ];
      description = ''
        Steam ROM Manager parser configurations written to
        {file}`$XDG_CONFIG_HOME/steam-rom-manager/userData/userConfigurations.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.userConfigurationsFile`.
      '';
    };

    userConfigurationsFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = ''
        Path to an existing Steam ROM Manager
        {file}`userConfigurations.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.userConfigurations`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.userSettings == { } || cfg.userSettingsFile == null;
        message = ''
          The `programs.steam-rom-manager.userSettings` and
          `programs.steam-rom-manager.userSettingsFile` options are mutually exclusive.
        '';
      }
      {
        assertion = cfg.userConfigurations == [ ] || cfg.userConfigurationsFile == null;
        message = ''
          The `programs.steam-rom-manager.userConfigurations` and
          `programs.steam-rom-manager.userConfigurationsFile` options are mutually exclusive.
        '';
      }
    ];

    home.packages = lib.optional (cfg.package != null) cfg.package;

    xdg.configFile = {
      "steam-rom-manager/userData/userSettings.json".source = userSettingsFile;
      "steam-rom-manager/userData/userConfigurations.json".source = userConfigurationsFile;
    };
  };
}
