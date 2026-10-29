{
  nixos = {
    services.matterjs-server = {
      enable = true;
      extraArgs = [ "--primary-interface=end0" ];
    };

    my.restic.matter = {
      repository = "/mnt/nas/restic/matter-restic";
      # systemd exposes this DynamicUser state directory through a symlink.
      path = "/var/lib/private/matterjs-server";
      service = "matterjs-server.service";
      mountPoint = "/mnt/nas/restic";
    };
  };
}
