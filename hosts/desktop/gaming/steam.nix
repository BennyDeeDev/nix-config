{
  nixos =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      jovian = {
        steam = {
          enable = true;
          autoStart = true;
          user = "benjamin";
          desktopSession = "niri";
        };

        decky-loader = {
          enable = true;
          package = pkgs.decky-loader.overridePythonAttrs (old: {
            postPatch = old.postPatch + ''
              substituteInPlace backend/decky_loader/localplatform/localplatformlinux.py \
                --replace-fail \
                  'env: ENV | None = {"LD_LIBRARY_PATH": ""}' \
                  'env: ENV | None = {"LD_LIBRARY_PATH": "", "PATH": os.environ.get("PATH", os.defpath)}'

              substituteInPlace backend/decky_loader/helpers.py \
                --replace-fail \
                  'env={} if localplatform.ON_LINUX else None' \
                  'env={"PATH": os.environ.get("PATH", os.defpath)} if localplatform.ON_LINUX else None'
            '';
          });
          extraPackages = [ pkgs.systemd ];
        };
      };

      systemd.tmpfiles.rules = [
        "C ${config.jovian.decky-loader.stateDir}/settings/Deck-Shelves/settings.json 0644 decky decky - ${../../../files/gaming/decky/Deck-Shelves/settings.json}"
      ];

      programs.dms-greeter.enable = lib.mkForce false;

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      # Create Steam CEF debugging file if it doesn't exist for Decky Loader.
      systemd.services.steam-cef-debug = lib.mkIf config.jovian.decky-loader.enable {
        description = "Create Steam CEF debugging file";
        serviceConfig = {
          Type = "oneshot";
          User = config.jovian.steam.user;
          ExecStart = "/bin/sh -c 'mkdir -p ~/.steam/steam && [ ! -f ~/.steam/steam/.cef-enable-remote-debugging ] && touch ~/.steam/steam/.cef-enable-remote-debugging || true'";
        };
        wantedBy = [ "multi-user.target" ];
      };

      services.displayManager.defaultSession = lib.mkForce "gamescope-wayland";
    };

  homeManager =
    { lib, ... }:
    {
      xdg.desktopEntries.return-to-gaming-mode = {
        name = "Return to Gaming Mode";
        comment = "Exit Desktop Mode and return to Steam";
        exec = "steamosctl switch-to-game-mode";
        icon = "steam";
        terminal = false;
        categories = [ "Game" ];
      };

      xdg.configFile."gtk-3.0/bookmarks".text = lib.mkAfter ''
        file:///mnt/games Games
      '';
    };
}
