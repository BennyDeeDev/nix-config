{
  homeManager =
    {
      config,
      nixConfig,
      lib,
      pkgs,
      ...
    }:
    {
      # The upstream service does not cover the initial restore or post-backup cloud upload.
      home.packages = [ pkgs.ludusavi ];

      home.file.".config/ludusavi/config.yaml".source =
        config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/gaming/ludusavi/config.yaml";

      home.activation.ludusaviBootstrap = lib.hm.dag.entryAfter [ "sops-nix.service" ] ''
        mkdir -p "$HOME/Backups/ludusavi"
        if [[ -z $(ls -A $HOME/Backups/ludusavi 2>/dev/null) ]]; then
          ${pkgs.rclone}/bin/rclone sync \
            --fast-list --ignore-checksum \
            "ludusavi-1759601223:/Ludusavi/ludusavi-backup" \
            "$HOME/Backups/ludusavi" && \
          ${pkgs.ludusavi}/bin/ludusavi restore --force && \
          ${pkgs.ludusavi}/bin/ludusavi backup --force || true
        fi
      '';

      systemd.user = {
        services.ludusavi-backup = {
          Unit.Description = "Ludusavi backup (NAS sync via Cloud settings)";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.ludusavi}/bin/ludusavi backup --force";
            ExecStartPost = "${pkgs.ludusavi}/bin/ludusavi cloud upload --force";
          };
        };
        timers.ludusavi-backup = {
          Unit.Description = "Run Ludusavi backup on a timer";
          Timer = {
            OnCalendar = "*:0/15";
            Persistent = true;
            RandomizedDelaySec = "2m";
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
    };
}
