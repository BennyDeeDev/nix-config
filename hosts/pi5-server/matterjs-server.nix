{
  nixos = {
    services.matterjs-server = {
      enable = true;
      extraArgs = [ "--primary-interface=end0" ];
    };

    my.restic.matter = {
      repository = "/mnt/nas/restic/matter-restic";
      path = "/var/lib/matterjs-server";
      service = "matterjs-server.service";
      mountPoint = "/mnt/nas/restic";
    };
  };
}
