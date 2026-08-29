{
  nixos = {
    security.rtkit.enable = true;

    services.pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };
}
