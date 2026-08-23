{
  nixos =
    { pkgs, ... }:
    {
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
            exec = ''/home/benjamin/Repos/nix-config/files/bin/reboot-to "Windows Boot Manager" reboot'';
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
    };

  homeManager =
    { nixConfig, ... }:
    {
      xdg.desktopEntries.windows = {
        name = "Windows";
        exec = ''${nixConfig}/files/bin/reboot-to "Windows Boot Manager" reboot'';
        comment = "Reboot to Windows Boot Manager";
        icon = "system-reboot-symbolic";
        type = "Application";
        categories = [ "System" ];
        settings."X-DesktopNames" = "Windows";
      };
    };
}
