{
  homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.stats ];

      targets.darwin.defaults."eu.exelban.Stats" = {
        Battery_state = 0;
        CombinedModules = 1;
        Disk_state = 1;
        GPU_state = 1;
        Network_state = 0;
        Sensors_state = 0;
        dockIcon = 0;
      };
    };
}
