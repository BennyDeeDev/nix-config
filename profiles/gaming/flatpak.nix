{ nix-flatpak }:

{
  nixos = {
    imports = [ nix-flatpak.nixosModules.nix-flatpak ];
    services.flatpak.enable = true;
  };

  homeManager =
    {
      config,
      pkgs,
      ...
    }:
    let
      steamRuntimeSwitcher = "${config.home.homeDirectory}/.local/share/Steam/ubuntu12_32/steam-runtime/scripts/switch-runtime.sh";

      steamHost = pkgs.writeTextFile {
        name = "steam-host";
        executable = true;
        destination = "/bin/steam-host";
        text = ''
          #!/bin/bash
          set -eu

          if [ "$#" -eq 0 ]; then
            printf 'usage: %s <command> [arguments...]\n' "$0" >&2
            exit 1
          fi

          if [ ! -x "${steamRuntimeSwitcher}" ]; then
            printf 'Steam runtime switcher not found: %s\n' "${steamRuntimeSwitcher}" >&2
            exit 1
          fi

          unset LD_PRELOAD

          exec "${steamRuntimeSwitcher}" --runtime="" -- "$@"
        '';
      };
    in
    {
      imports = [ nix-flatpak.homeManagerModules.nix-flatpak ];
      home.packages = [ steamHost ];

      services.flatpak.enable = true;

      services.flatpak.update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
}
