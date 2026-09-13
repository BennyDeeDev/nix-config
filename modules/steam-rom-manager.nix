{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.steam-rom-manager;

  jsonFormat = pkgs.formats.json { };

  parserConfigurationType = lib.types.submodule {
    freeformType = jsonFormat.type;

    options = {
      version = lib.mkOption {
        type = lib.types.int;
        default = 29;
      };

      steamDirectory = lib.mkOption {
        type = lib.types.str;
        default = "\${steamdirglobal}";
      };

      executable = lib.mkOption {
        type = lib.types.submodule {
          freeformType = jsonFormat.type;

          options.shortcutPassthrough = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
        default = { };
      };

      titleFromVariable = lib.mkOption {
        type = lib.types.submodule {
          freeformType = jsonFormat.type;

          options.limitToGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
        default = {
          limitToGroups = [ ];
        };
      };

      sortAsFromVariable = lib.mkOption {
        type = lib.types.submodule {
          freeformType = jsonFormat.type;

          options.limitToGroups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
        default = { };
      };

      onlineImageQueries = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "\${fuzzyTitle}" ];
      };

      imageProviderAPIs = lib.mkOption {
        type = lib.types.submodule {
          freeformType = jsonFormat.type;

          options.sgdb = lib.mkOption {
            inherit (jsonFormat) type;
            default = { };
          };
        };
        default = { };
      };

      defaultImage = lib.mkOption {
        inherit (jsonFormat) type;
        default = { };
      };

      localImages = lib.mkOption {
        inherit (jsonFormat) type;
        default = { };
      };

      overlayImages = lib.mkOption {
        inherit (jsonFormat) type;
        default = { };
      };

      userAccounts = lib.mkOption {
        type = lib.types.submodule {
          freeformType = jsonFormat.type;

          options.specifiedAccounts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = cfg.accounts;
          };
        };
        default = { };
      };
    };
  };

  userSettingsType = lib.types.submodule {
    freeformType = jsonFormat.type;

    options = {
      version = lib.mkOption {
        type = lib.types.int;
        default = 11;
      };

      environmentVariables = lib.mkOption {
        type = lib.types.submodule {
          freeformType = jsonFormat.type;

          options.userAccounts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = cfg.accounts;
          };
        };
        default = { };
      };
    };
  };

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

  userVariablesFile =
    if cfg.userVariablesFile != null then
      cfg.userVariablesFile
    else
      jsonFormat.generate "userVariables.json" cfg.userVariables;

  userExceptionsFile =
    if cfg.userExceptionsFile != null then
      cfg.userExceptionsFile
    else
      jsonFormat.generate "userExceptions.json" cfg.userExceptions;

  controllerTemplatesFile =
    if cfg.controllerTemplatesFile != null then
      cfg.controllerTemplatesFile
    else
      jsonFormat.generate "controllerTemplates.json" cfg.controllerTemplates;

  userDataDir = "${config.xdg.configHome}/steam-rom-manager/userData";

  installUserDataFile = source: filename: ''
    run install -Dm644 $VERBOSE_ARG \
      ${lib.escapeShellArg source} \
      ${lib.escapeShellArg "${userDataDir}/${filename}"}
  '';
in
{
  meta.maintainers = [ ];

  options.programs.steam-rom-manager = {
    enable = lib.mkEnableOption "Steam ROM Manager";

    package = lib.mkPackageOption pkgs "steam-rom-manager" {
      nullable = true;
    };

    accounts = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      description = "Steam account names used by generated parsers.";
    };

    userSettings = lib.mkOption {
      type = userSettingsType;
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
      type = lib.types.listOf parserConfigurationType;
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

    userVariables = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        User-defined variables written to
        {file}`$XDG_CONFIG_HOME/steam-rom-manager/userData/userVariables.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.userVariablesFile`.
      '';
    };

    userVariablesFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = ''
        Path to an existing Steam ROM Manager
        {file}`userVariables.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.userVariables`.
      '';
    };

    userExceptions = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        User-defined parser exceptions written to
        {file}`$XDG_CONFIG_HOME/steam-rom-manager/userData/userExceptions.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.userExceptionsFile`.
      '';
    };

    userExceptionsFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = ''
        Path to an existing Steam ROM Manager
        {file}`userExceptions.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.userExceptions`.
      '';
    };

    controllerTemplates = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        Controller templates written to
        {file}`$XDG_CONFIG_HOME/steam-rom-manager/userData/controllerTemplates.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.controllerTemplatesFile`.
      '';
    };

    controllerTemplatesFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = ''
        Path to an existing Steam ROM Manager
        {file}`controllerTemplates.json`.

        This option is mutually exclusive with
        {option}`programs.steam-rom-manager.controllerTemplates`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.userSettingsFile == null
          ||
            cfg.userSettings == {
              version = 11;
              environmentVariables.userAccounts = cfg.accounts;
            };
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
      {
        assertion = cfg.userVariables == { } || cfg.userVariablesFile == null;
        message = ''
          The `programs.steam-rom-manager.userVariables` and
          `programs.steam-rom-manager.userVariablesFile` options are mutually exclusive.
        '';
      }
      {
        assertion = cfg.userExceptions == { } || cfg.userExceptionsFile == null;
        message = ''
          The `programs.steam-rom-manager.userExceptions` and
          `programs.steam-rom-manager.userExceptionsFile` options are mutually exclusive.
        '';
      }
      {
        assertion = cfg.controllerTemplates == { } || cfg.controllerTemplatesFile == null;
        message = ''
          The `programs.steam-rom-manager.controllerTemplates` and
          `programs.steam-rom-manager.controllerTemplatesFile` options are mutually exclusive.
        '';
      }
    ];

    home.packages = lib.optional (cfg.package != null) cfg.package;

    home.activation.steamRomManagerConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      verboseEcho "Installing Steam ROM Manager user data"

      ${installUserDataFile userSettingsFile "userSettings.json"}
      ${installUserDataFile userConfigurationsFile "userConfigurations.json"}
      ${installUserDataFile userVariablesFile "userVariables.json"}
      ${installUserDataFile userExceptionsFile "userExceptions.json"}
      ${installUserDataFile controllerTemplatesFile "controllerTemplates.json"}
    '';
  };
}
