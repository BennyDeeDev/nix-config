{ config, lib, ... }:
let
  primaryUser = config.system.primaryUser;
in
{
  config = lib.mkIf (primaryUser != null) {
    users.users.${primaryUser} = {
      name = primaryUser;
      home = "/Users/${primaryUser}";
    };
  };
}
