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
      home.packages = [ pkgs.ludusavi ];

      home.file.".config/ludusavi/config.yaml".source =
        config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/gaming/ludusavi/config.yaml";

      home.activation.ludusaviBootstrap = lib.hm.dag.entryAfter [ "sops-nix.service" ] ''
        mkdir -p "$HOME/Backups/ludusavi"
        if [[ -z $(ls -A $HOME/Backups/ludusavi 2>/dev/null) ]]; then
          ${lib.getExe pkgs.rclone} sync \
            --fast-list --ignore-checksum \
            "ludusavi-1759601223:/Ludusavi/ludusavi-backup" \
            "$HOME/Backups/ludusavi" && \
          ${lib.getExe pkgs.ludusavi} restore --force && \
          ${lib.getExe pkgs.ludusavi} backup --force || true
        fi
      '';

      systemd.user = {
        services.ludusavi-backup = {
          Unit.Description = "Ludusavi backup (NAS sync via Cloud settings)";
          Service = {
            Type = "oneshot";
            ExecStart = "${lib.getExe pkgs.ludusavi} backup --force";
            ExecStartPost = "${lib.getExe pkgs.ludusavi} cloud upload --force";
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
