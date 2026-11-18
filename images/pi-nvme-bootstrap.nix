inputs:

let
  piBootstrap = import ./pi-bootstrap.nix inputs;
in
{
  nixos =
    { lib, ... }:
    {
      imports = [ piBootstrap.nixos ];

      my.pi.bootMedium = "nvme";

      sdImage = {
        rootVolumeLabel = "NIXOS_NVME";
        firmwareSize = 512;
        # Keep upstream firmware population, including the overridden U-Boot.
        populateFirmwareCommands = lib.mkAfter ''
          chmod u+w firmware/config.txt
          cat >> firmware/config.txt <<'EOF'

          [pi5]
          dtparam=pciex1
          EOF
        '';
      };
    };
}
