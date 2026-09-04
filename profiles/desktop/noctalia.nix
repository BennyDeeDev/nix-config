{
  noctalia,
  noctalia-greeter,
}:

{
  nixos = {
    imports = [ noctalia-greeter.nixosModules.default ];

    users.groups.greeter = { };
    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
    };

    programs.noctalia-greeter.enable = true;
  };

  homeManager =
    { config, ... }:
    {
      imports = [ noctalia.homeModules.default ];

      programs.noctalia = {
        enable = true;
        settings = ../../files/noctalia/config.toml;
      };
    };
}
