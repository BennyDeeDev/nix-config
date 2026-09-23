{
  nixos =
    { config, ... }:
    {
      assertions = [
        {
          assertion = config.fileSystems."/".fsType == "btrfs";
          message = "The system profile requires a Btrfs root filesystem.";
        }
      ];

      boot.supportedFilesystems = [ "btrfs" ];

      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = [ "/" ];
      };
    };
}
