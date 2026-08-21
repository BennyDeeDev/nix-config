{ config, lib, ... }:
{
  config = lib.mkIf (config.system.primaryUser != null) {
    users.users.${config.system.primaryUser} = {
      name = config.system.primaryUser;
      home = "/Users/${config.system.primaryUser}";
    };
  };
}
