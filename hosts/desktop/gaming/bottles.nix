{
  homeManager =
    { config, dotfiles, ... }:
    {
      services.flatpak = {
        packages = [ "com.usebottles.bottles" ];
        overrides."com.usebottles.bottles".Context.filesystems = [
          "/nix/store:ro"
          "~/Games/PC:rw"
          "${dotfiles}/files/gaming/bottles:rw"
          "/mnt/bazzite/bazzite/Games/PC:rw"
        ];
      };

      home.file = {
        ".var/app/com.usebottles.bottles/data/bottles/bottles/Games-Exe-Runner-Proton/bottle.yml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotfiles}/files/gaming/bottles/bottle.yml";
        ".var/app/com.usebottles.bottles/data/bottles/bottles/Games-Exe-Runner-Proton/dosdevices/d:".source =
          config.lib.file.mkOutOfStoreSymlink "/mnt/bazzite/bazzite/Games/PC";
      };
    };
}
