{
  nixos =
    { ... }:
    {
      security.sudo.extraConfig = ''
        Defaults timestamp_type=tty,timestamp_timeout=-1
      '';
    };

  darwin =
    { ... }:
    {
      security.pam.services.sudo_local.touchIdAuth = true;
    };
}
