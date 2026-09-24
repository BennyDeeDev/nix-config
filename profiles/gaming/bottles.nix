{
  homeManager =
    { config, ... }:
    let
      portableGamesPath = config.my.gaming.portableGamesPath;
    in
    {
      services.flatpak = {
        packages = [ "com.usebottles.bottles" ];
        overrides."com.usebottles.bottles" = {
          Context.filesystems = [
            "/nix/store:ro"
            "${config.my.gaming.gamesPath}/PC:ro"
            "${portableGamesPath}/PC:ro"
            "${portableGamesPath}/Bottles:rw"
          ];
        };
      };

      home.file.".var/app/com.usebottles.bottles/data/bottles/bottles/gaming-portable-bottle".source =
        config.lib.file.mkOutOfStoreSymlink "${portableGamesPath}/Bottles/gaming-portable-bottle";
    };
}
