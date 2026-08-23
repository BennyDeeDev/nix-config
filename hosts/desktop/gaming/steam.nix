{
  nixos =
    { lib, ... }:
    {
      jovian.steam = {
        enable = true;
        autoStart = true;
        user = "benjamin";
        desktopSession = "niri";
      };

      programs.dms-greeter.enable = lib.mkForce false;

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
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
