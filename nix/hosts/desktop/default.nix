{
  inputs,
  lib,
  pkgs,
  repoRoot,
  workstationProfile,
  ...
}:

let
  gaming = import ../../../hosts/desktop/gaming {
    inherit inputs lib repoRoot;
  };
in
{
  imports = [
    ../../system/base.nix
    ../../system/desktop.nix
    ./disko.nix
    ./hardware-configuration.nix
    ../../modules/sops.nix
    ../../modules/nas.nix
  ];

  networking.hostName = "nixos";

  environment.systemPackages = with pkgs; [
    sbctl
  ];

  sops.defaultSopsFile = ../../secrets/desktop.yaml;

  host.nas = {
    uid = 1000;
    gid = 100;
    shares = [
      "Homelab"
      "Benjamin"
      "Ludusavi"
      "Restic"
    ];
  };

  # Lanzaboote replaces systemd-boot and signs boot artifacts.
  # Keys are provisioned at /var/lib/sbctl via `sudo sbctl create-keys`.
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
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
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  boot.supportedFilesystems = [
    "btrfs"
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      FastConnectable = true;
    };
    Policy.AutoEnable = true;
  };
  services.blueman.enable = true;
  services.pcscd.enable = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.amdgpu.initrd.enable = true;

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  services.displayManager.defaultSession = "niri";

  # TODO: remove once nixos is stable
  fileSystems."/mnt/bazzite" = {
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S7HDNJ0Y413952T-part3";
    fsType = "btrfs";
    options = [
      "rw"
      "subvol=/home"
      "relatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "nofail"
    ];
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  virtualisation.libvirtd.enable = true;

  home-manager.users.benjamin = { dotfiles, ... }: {
    imports = [
      workstationProfile.homeManager
      gaming.homeManager
      ../../home/sops.nix
    ];
    home.packages = with pkgs; [
      keymapp
      asdbctl
    ];
    sops.defaultSopsFile = ../../secrets/desktop.yaml;
    dotfiles.sops.yubikeyIdentity =
      "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
    home.username = "benjamin";
    home.homeDirectory = "/home/benjamin";
    home.stateVersion = "25.11";
    programs.zsh.shellAliases.nrs = "sudo nixos-rebuild switch --flake ${dotfiles}#desktop";
    programs.git.settings.user = {
      name = "BennyDeeDev";
      email = "45900418+BennyDeeDev@users.noreply.github.com";
    };
    xdg.desktopEntries.windows = {
      name = "Windows";
      exec = ''${dotfiles}/files/bin/reboot-to "Windows Boot Manager" reboot'';
      comment = "Reboot to Windows Boot Manager";
      icon = "system-reboot-symbolic";
      type = "Application";
      categories = [ "System" ];
      settings."X-DesktopNames" = "Windows";
    };
  };
}
