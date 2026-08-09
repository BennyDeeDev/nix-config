{ pkgs, config, ... }:

{
  imports = [ ./sops.nix ];

  # Firewall disabled because HA + OTBR + matter-server all depend on inbound
  # multicast for device discovery (mDNS/Zeroconf on 5353/udp, SSDP on 1900/udp)
  # and Matter commissioning uses ephemeral UDP ports the spec explicitly warns
  # against filtering (see matter-js server docs/os_requirements.md).
  # NixOS's firewall blocks multicast by default — re-enabling requires hand
  # crafting accept rules for 224.0.0.251/ff02::fb and 239.255.255.250, plus
  # setting networking.firewall.checkReversePath = "loose" so rpfilter doesn't
  # silently eat multicast replies. The Fritz!Box remains the WAN perimeter.
  networking.firewall.enable = false;

  # Mainline kernel — cached, fast build. Overrides the nixos-hardware vendor pin.
  boot.kernelPackages = pkgs.linuxPackages;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  sops.secrets."benjamin-password" = {
    sopsFile = ../secrets/common.yaml;
    neededForUsers = true;
  };

  users.users.benjamin = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets."benjamin-password".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHW2qr7cup1ALuIpnhUoJP8dLjv/yhGfuh/1Vni2lSbd"
    ];
  };

  programs.zsh.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    git
    vim
    btop
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [ "benjamin" ];

  system.stateVersion = "26.05";
}
