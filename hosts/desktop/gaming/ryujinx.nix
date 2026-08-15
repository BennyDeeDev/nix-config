{
  homeManager =
    {
      config,
      dotfiles,
      lib,
      pkgs,
      ...
    }:
    {
      services.flatpak = {
        packages = [ "io.github.ryubing.Ryujinx" ];
        overrides."io.github.ryubing.Ryujinx".Context = {
          filesystems = [
            "/nix/store:ro"
            "~/Games/Switch:ro"
            "${dotfiles}/files/gaming/ryujinx:rw"
            "/mnt/bazzite/bazzite/Games/Switch:ro"
          ];
          shared = [ "!network" ];
        };
      };

      home.file.".var/app/io.github.ryubing.Ryujinx/config/Ryujinx/Config.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfiles}/files/gaming/ryujinx/Config.json";

      home.activation = {
        ryujinxKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          keys_dir="$HOME/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/system"
          if [[ ! -f $keys_dir/prod.keys ]]; then
            mkdir -p "$keys_dir"
            ${pkgs.unzip}/bin/unzip -oj \
              '/mnt/nas/homelab/data/media/games/Switch/Firmware/ProdKeys.net-v20.3.0.zip' \
              -d "$keys_dir"
          fi
        '';
        ryujinxFirmware = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          registered="$HOME/.var/app/io.github.ryubing.Ryujinx/config/Ryujinx/bis/system/Contents/registered"
          sentinel="$registered/.installed"
          if [[ ! -f $sentinel ]]; then
            mkdir -p "$registered"
            tmp=$(mktemp -d)
            ${pkgs.unzip}/bin/unzip -oj \
              '/mnt/nas/homelab/data/media/games/Switch/Firmware/Firmware.20.3.0.zip' \
              -d "$tmp"
            for nca in "$tmp"/*.nca; do
              dir="$registered/$(basename "$nca")"
              mkdir -p "$dir"
              mv "$nca" "$dir/00"
            done
            rm -rf "$tmp"
            touch "$sentinel"
          fi
        '';
      };
    };
}
