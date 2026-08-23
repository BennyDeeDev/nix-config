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
      home.packages = [ pkgs.steam-rom-manager ];

      home.file = {
        ".config/steam-rom-manager/userData/userConfigurations.json".source =
          config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/gaming/steam-rom-manager/userConfigurations.json";
        ".config/steam-rom-manager/userData/userSettings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/gaming/steam-rom-manager/userSettings.json";
      };

      home.activation.steamRomManagerBootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        sentinel="$HOME/.local/share/steam-rom-manager/bootstrapped"
        if [[ ! -f $sentinel ]]; then
          ${lib.getExe' pkgs.procps "pkill"} steam || true
          ${lib.getExe pkgs.steam-rom-manager} add
          mkdir -p "$(dirname $sentinel)"
          touch "$sentinel"
        fi
      '';
    };
}
