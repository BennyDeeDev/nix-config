{
  nixos =
    { ... }:
    {
      security.sudo.extraConfig = ''
        Defaults timestamp_type=tty,timestamp_timeout=-1
      '';
    };

}
