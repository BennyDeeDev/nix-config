{
  homeManager =
    { config, ... }:
    {
      services.flatpak = {
        packages = [ "io.github.ryubing.Ryujinx" ];
        overrides."io.github.ryubing.Ryujinx".Context = {
          filesystems = [
            "/nix/store:ro"
            "${config.my.gaming.gamesPath}/Switch:ro"
          ];
          shared = [ "!network" ];
        };
      };
    };
}
