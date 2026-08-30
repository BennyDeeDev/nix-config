{
  nixos = {
    security.rtkit.enable = true;

    services.pipewire = {
      alsa.enable = true;
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
