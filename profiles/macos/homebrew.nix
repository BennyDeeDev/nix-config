{ nix-homebrew }:

{
  darwin =
    { config, ... }:
    {
      imports = [ nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        enable = true;
        user = config.system.primaryUser;
        autoMigrate = true;
      };
    };
}
