{ ... }:

{
  homeManager =
    { config, ... }:
    {
      programs.rclone.enable = true;

      sops.secrets."smb-username" = { };
      sops.secrets."smb-password-rclone-obscured" = { };

      sops.templates."rclone.conf" = {
        content = ''
          [ludusavi-1759601223]
          type = smb
          host = 192.168.178.254
          port = 445
          user = ${config.sops.placeholder."smb-username"}
          pass = ${config.sops.placeholder."smb-password-rclone-obscured"}
        '';
        path = "${config.xdg.configHome}/rclone/rclone.conf";
      };
    };
}
