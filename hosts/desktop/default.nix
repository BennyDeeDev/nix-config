inputs@{
  disko,
  nix-flatpak,
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  sops = import ../../modules/sops.nix { inherit sops-nix; };
  nas = import ../../modules/nas.nix;
  gaming = import ./gaming { inherit nix-flatpak; };
in
{
  config,
  pkgs,
  ...
}:

{
  imports = [
    profiles.base.nixos
    profiles.system.nixos
    profiles.graphical.nixos
    nas.nixos
    gaming.nixos
    disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";

  home-manager = {
    extraSpecialArgs.dotfiles = "/home/benjamin/Repos/dotfiles";
    users.benjamin =
      { dotfiles, lib, ... }:
      {
        imports = [
          profiles.system.homeManager
          profiles.terminal.homeManager
          profiles.graphical.homeManager
          sops.homeManager
          gaming.homeManager
        ];

        xdg.configFile."gtk-3.0/bookmarks".text = lib.mkAfter ''
          file:///mnt/nas/benjamin NAS - Benjamin
          file:///mnt/nas/homelab NAS - Homelab
          file:///mnt/nas/ludusavi NAS - Ludusavi
          file:///mnt/nas/restic NAS - Restic
        '';

        sops.defaultSopsFile = ../../secrets/desktop.yaml;
        my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
        home = {
          username = "benjamin";
          homeDirectory = "/home/benjamin";
          stateVersion = "25.11";
        };
        programs = {
          zsh.shellAliases.nrs = "sudo nixos-rebuild switch --flake ${dotfiles}#desktop";
          git.settings.user = {
            name = "BennyDeeDev";
            email = "45900418+BennyDeeDev@users.noreply.github.com";
          };
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
  };
  programs.dank-material-shell.greeter.configHome = "/home/benjamin";

  sops = {
    defaultSopsFile = ../../secrets/desktop.yaml;
    secrets."benjamin-password" = {
      sopsFile = ../../secrets/common.yaml;
      neededForUsers = true;
    };
  };

  my.sops.smartcard.enable = true;

  users.users.benjamin = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    hashedPasswordFile = config.sops.secrets."benjamin-password".path;
  };

  my.nas = {
    uid = 1000;
    gid = 100;
    shares = [
      "Homelab"
      "Benjamin"
      "Ludusavi"
      "Restic"
    ];
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    amdgpu.initrd.enable = true;
  };

  fileSystems = {
    "/mnt/bazzite" = {
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
    "/var/log".neededForBoot = true;
  };

  environment.systemPackages = [ pkgs.efibootmgr ];
  security.sudo.extraRules = [
    {
      users = [ "benjamin" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/efibootmgr";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.displayManager.sessionPackages = [
    (
      pkgs.makeDesktopItem {
        name = "windows";
        destination = "/share/wayland-sessions";
        desktopName = "Windows";
        comment = "Reboot to Windows Boot Manager";
        exec = ''/home/benjamin/Repos/dotfiles/files/bin/reboot-to "Windows Boot Manager" reboot'';
        type = "Application";
        categories = [ "System" ];
        extraConfig = {
          "X-DesktopNames" = "Windows";
        };
      }
      // {
        providedSessions = [ "windows" ];
      }
    )
  ];

  system.stateVersion = "25.11";
}
