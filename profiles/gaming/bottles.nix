{
  homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      portableGamesPath = config.my.gaming.portableGamesPath;
      bottleName = "gaming-portable-bottle";

      profiles = {
        "sdl-off-hidraw-on" = {
          enableSdl = false;
          disableHidraw = false;
        };

        "sdl-off-hidraw-off" = {
          enableSdl = false;
          disableHidraw = true;
        };

        "sdl-on-hidraw-on" = {
          enableSdl = true;
          disableHidraw = false;
        };

        "sdl-on-hidraw-off" = {
          enableSdl = true;
          disableHidraw = true;
        };
      };

      mkBottlesLauncher =
        profileName: profile:
        pkgs.writeShellApplication {
          name = "bottles-${profileName}";
          runtimeInputs = [ pkgs.flatpak ];
          text = ''
            set -eu

            if [ "$#" -eq 0 ]; then
              printf 'usage: %s <command> [arguments...]\n' "$0" >&2
              exit 1
            fi

            bottle="${bottleName}"
            key='HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\WineBus'

            setRegistryValue() {
              flatpak run \
                --command=bottles-cli \
                com.usebottles.bottles \
                reg add \
                -b "$bottle" \
                -k "$key" \
                -v "$1" \
                -d "$2" \
                -t REG_DWORD
            }

            setRegistryValue "Enable SDL" "${if profile.enableSdl then "1" else "0"}"
            setRegistryValue "DisableHidraw" "${if profile.disableHidraw then "1" else "0"}"

            exec "$@"
          '';
        };

      launchers = lib.mapAttrsToList mkBottlesLauncher profiles;
    in
    {
      home.packages = launchers;

      services.flatpak = {
        packages = [ "com.usebottles.bottles" ];
        overrides."com.usebottles.bottles" = {
          Context.filesystems = [
            "/nix/store:ro"
            "${config.my.gaming.gamesPath}/PC:rw"
            "${portableGamesPath}/PC:rw"
            "${portableGamesPath}/Bottles:rw"
          ];
        };
      };

      home.file.".var/app/com.usebottles.bottles/data/bottles/bottles/gaming-portable-bottle".source =
        config.lib.file.mkOutOfStoreSymlink "${portableGamesPath}/Bottles/gaming-portable-bottle";
    };
}
