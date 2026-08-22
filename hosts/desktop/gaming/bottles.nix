{
  homeManager =
    { config, nixConfig, ... }:
    {
      services.flatpak = {
        packages = [ "com.usebottles.bottles" ];
        overrides."com.usebottles.bottles".Context.filesystems = [
          "/nix/store:ro"
          "~/Games/PC:rw"
          "${nixConfig}/files/gaming/bottles:rw"
          "/mnt/games/PC:rw"
        ];
      };

      home.file = {
        ".var/app/com.usebottles.bottles/data/bottles/bottles/Games-Exe-Runner-Proton/bottle.yml".source =
          config.lib.file.mkOutOfStoreSymlink "${nixConfig}/files/gaming/bottles/bottle.yml";
        ".var/app/com.usebottles.bottles/data/bottles/bottles/Games-Exe-Runner-Proton/dosdevices/d:".source =
          config.lib.file.mkOutOfStoreSymlink "/mnt/games/PC";
      };
    };
}
