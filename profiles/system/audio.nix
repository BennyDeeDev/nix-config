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
    { lib, pkgs, ... }:
    lib.mkIf pkgs.stdenv.isLinux {
      home.packages = with pkgs; [
        # playerctl is called directly; no playerctld daemon is needed.
        playerctl
        wiremix

        # These PulseAudio clients control PipeWire through its compatibility layer.
        pamixer
        pavucontrol
        pulseaudio
      ];
    };
}
