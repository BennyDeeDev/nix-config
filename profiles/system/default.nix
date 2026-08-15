{ lanzaboote }:

let
  darwin = import ./darwin.nix;
  audio = import ./audio.nix;
  bluetooth = import ./bluetooth.nix;
  boot = import ./boot.nix { inherit lanzaboote; };
  btrfs = import ./btrfs.nix;
  libvirt = import ./libvirt.nix;
  networkmanager = import ./networkmanager.nix;
  podman = import ./podman.nix;
  printing = import ./printing.nix;
in
{
  nixos =
    { pkgs, ... }:
    {
      imports = [
        audio.nixos
        bluetooth.nixos
        boot.nixos
        btrfs.nixos
        libvirt.nixos
        networkmanager.nixos
        podman.nixos
        printing.nixos
      ];

      nix.settings.auto-optimise-store = true;
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
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

  inherit (darwin) darwin;

  homeManager = {
    imports = [
      audio.homeManager
      bluetooth.homeManager
      networkmanager.homeManager
      podman.homeManager
    ];
  };
}
