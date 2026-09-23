{ jovian }:

{
  nixos =
    { lib, ... }:
    {
      imports = [ jovian.nixosModules.jovian ];

      jovian.steam = {
        enable = true;
        autoStart = true;
        user = "benjamin";
        desktopSession = "plasma";
      };

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      services.displayManager.defaultSession = lib.mkForce "gamescope-wayland";
    };

  homeManager = {
    xdg.desktopEntries.return-to-gaming-mode = {
      name = "Return to Gaming Mode";
      comment = "Exit Desktop Mode and return to Steam";
      exec = "steamosctl switch-to-game-mode";
      icon = "steam";
      terminal = false;
      categories = [ "Game" ];
    };
  };
}
