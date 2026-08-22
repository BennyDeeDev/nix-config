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

      programs.dank-material-shell.greeter.enable = lib.mkForce false;

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      services.blueman.enable = lib.mkForce false;
      services.displayManager.defaultSession = lib.mkForce "gamescope-wayland";
    };
}
