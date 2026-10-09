{
  nixos = {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
  };

  homeManager = {
    wayland.desktopManager.cosmic.enable = true;
  };
}
