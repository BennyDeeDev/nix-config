{
  nixos =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.beszel.agent;
    in
    {
      options.my.beszel.agent = {
        enable = lib.mkEnableOption "Beszel agent";
        hubUrl = lib.mkOption {
          type = lib.types.str;
          description = "Hub URL the Beszel agent connects to.";
        };
        hubPublicKey = lib.mkOption {
          type = lib.types.str;
          default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWd4r/S3y8EYj4YPObC+0tSJiWyso1a7NfMi46Gz0wz";
          description = "Hub public SSH key trusted by the agent.";
        };
        tokenSopsFile = lib.mkOption {
          type = lib.types.path;
          description = "Host-specific SOPS file containing the agent token.";
        };
      };

      config = lib.mkIf cfg.enable {
        sops.secrets."beszel-agent-token".sopsFile = cfg.tokenSopsFile;

        sops.templates."beszel-agent-env".content = ''
          TOKEN=${config.sops.placeholder."beszel-agent-token"}
        '';

        services.beszel.agent = {
          enable = true;
          openFirewall = false;
          environment = {
            KEY = cfg.hubPublicKey;
            HUB_URL = cfg.hubUrl;
            DISABLE_SSH = "true";
          };
          environmentFile = config.sops.templates."beszel-agent-env".path;
        };
      };
    };
}
