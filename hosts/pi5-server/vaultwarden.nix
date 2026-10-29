{
  nixos =
    { pkgs, ... }:
    {
      services.vaultwarden = {
        enable = true;
        webVaultPackage = pkgs.vaultwarden.webvault.overrideAttrs (oldAttrs: {
          postPatch = (oldAttrs.postPatch or "") + ''
            substituteInPlace libs/common/src/platform/misc/utils.ts \
              --replace-fail \
              "static readonly minimumPasswordLength = 12;" \
              "static readonly minimumPasswordLength = 8;"
          '';
        });
        config = {
          DOMAIN = "https://vault.benjaminderksen.com";
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          # Keep registration enabled for this trusted, LAN-only instance.
          SIGNUPS_ALLOWED = true;
        };
      };

      my.restic.vaultwarden = {
        repository = "/mnt/nas/restic/vaultwarden-restic";
        path = "/var/lib/vaultwarden";
        service = "vaultwarden.service";
        mountPoint = "/mnt/nas/restic";
      };
    };
}
