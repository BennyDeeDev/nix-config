{
  homeManager =
    { config, ... }:
    {
      services.flatpak = {
        packages = [ "com.usebottles.bottles" ];
        overrides."com.usebottles.bottles" = {
          Context.filesystems = [
            "/nix/store:ro"
          ]
          ++ map (gamesPath: "${gamesPath}/PC:rw") config.my.gaming.gamesPaths;
        };
      };
    };
}
