{
  homeManager =
    { config, ... }:
    {
      services.flatpak = {
        packages = [ "com.usebottles.bottles" ];
        overrides."com.usebottles.bottles" = {
          Context.filesystems = [
            "/nix/store:ro"
            "${config.my.gaming.gamesPath}/PC:ro"
            "${config.my.gaming.portableGamesPath}/PC:ro"
            "${config.my.gaming.portableGamesPath}/Bottles:rw"
          ];
        };
      };

      home.file.".var/app/com.usebottles.bottles/data/bottles/bottles/gaming-portable-bottle".source =
        config.lib.file.mkOutOfStoreSymlink "${config.my.gaming.portableGamesPath}/Bottles/gaming-portable-bottle";
    };
}
