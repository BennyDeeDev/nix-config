{
  nixos = {
    services.matterjs-server = {
      enable = true;
      extraArgs = [ "--primary-interface=end0" ];
    };

    systemd.services.matterjs-server.serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    my.restic.matter = {
      repository = "/mnt/nas/restic/matter-restic";
      path = "/var/lib/private/matterjs-server";
      service = "matterjs-server.service";
      mountPoint = "/mnt/nas/restic";
    };
  };
}
