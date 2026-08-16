{
  nixos = { ... }: {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
  };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        playerctl
        wiremix
        pamixer
        pavucontrol
        pulseaudio
      ];
    };

}
