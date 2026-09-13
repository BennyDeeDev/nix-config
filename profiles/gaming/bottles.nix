{
  homeManager =
    { config, ... }:
    {
      services.flatpak = {
        packages = [ "com.usebottles.bottles" ];
        overrides."com.usebottles.bottles".Context.filesystems = [
          "/nix/store:ro"
          "${config.my.gaming.gamesPath}/PC:rw"
        ];
      };
    };
}
