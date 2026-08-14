{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.printing.enable = true;
  environment.systemPackages = with pkgs; [
    cups-pk-helper
    efibootmgr
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.keyboard.zsa.enable = true;

  services.udev.packages = [ pkgs.asdbctl ];

  programs.dconf.enable = true;

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/benjamin";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "compose:ralt";
  };

  # Allow users to write brave theme policy (used by omarchy-theme-set)
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession = {
      enable = true;
      args = [
        "--mangoapp"
        "--mouse-sensitivity=0.5"
      ];
      steamArgs = [
        "-steamdeck"
        "-steamos3"
      ];
    };
    extraPackages = [
      (pkgs.writeShellScriptBin "steamos-session-select" "steam -shutdown")
      (pkgs.writeShellScriptBin "steamos-update" "exit 7")
      (pkgs.writeShellScriptBin "steamos-select-branch" ''echo "Not applicable for this OS"'')
      (pkgs.writeShellScriptBin "jupiter-biosupdate" ''echo "No updates configured for this bios"; exit 0'')
    ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

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
    (pkgs.makeDesktopItem {
      name = "windows";
      destination = "/share/wayland-sessions";
      desktopName = "Windows";
      comment = "Reboot to Windows Boot Manager";
      exec = ''/home/benjamin/Repos/dotfiles/files/bin/reboot-to "Windows Boot Manager" reboot'';
      type = "Application";
      categories = [ "System" ];
      extraConfig = { "X-DesktopNames" = "Windows"; };
    } // { providedSessions = [ "windows" ]; })
  ];
}
