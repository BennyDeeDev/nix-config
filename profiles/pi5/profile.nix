{
  nixos =
    { ... }:
    {
      nix.settings.trusted-users = [ "benjamin" ];
    };
}
