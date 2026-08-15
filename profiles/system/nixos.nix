{ ... }:

{
  nixos =
    { config, pkgs, ... }:
    {
      assertions = [
        {
          assertion = config.fileSystems."/".fsType == "btrfs";
          message = "The system profile requires a Btrfs root filesystem.";
        }
      ];

      nixpkgs.config.allowUnfree = true;
      nix.settings.auto-optimise-store = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      boot = {
        binfmt.emulatedSystems = [ "aarch64-linux" ];
        supportedFilesystems = [ "btrfs" ];
      };

      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = [ "/" ];
      };

      programs.fuse.enable = true;
      programs.vim.defaultEditor = true;
      zramSwap.enable = true;
      services.envfs.enable = true;
      programs.nix-ld.enable = true;

      environment.systemPackages = [ pkgs.gcc ];
      security.sudo.extraConfig = ''
        Defaults timestamp_type=tty,timestamp_timeout=-1
      '';
    };
}
