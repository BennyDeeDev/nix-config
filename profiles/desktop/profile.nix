{
  nixos = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.dconf.enable = true;
    security.sudo.extraConfig = ''
      Defaults timestamp_type=tty,timestamp_timeout=-1
    '';
    security.polkit.enable = true;
    services.printing.enable = true;
    virtualisation.podman.enable = true;
  };
}
