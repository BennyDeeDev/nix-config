{ inputs, ... }:

{
  nixos =
    { lib, pkgs, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      boot = {
        loader = {
          systemd-boot = {
            enable = lib.mkForce false;
            configurationLimit = 10;
          };
          efi.canTouchEfiVariables = true;
          timeout = 0;
        };

        consoleLogLevel = 3;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "udev.log_level=3"
          "systemd.show_status=auto"
        ];
        plymouth.enable = true;

        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          configurationLimit = 10;
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            autoReboot = true;
          };
        };
      };

      # Lanzaboote manages signing but does not expose its administrative CLI.
      environment.systemPackages = [ pkgs.sbctl ];
    };
}
