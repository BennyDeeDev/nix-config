{ jovian }:

{
  homeManager =
    { pkgs, ... }:
    {
      systemd.user.services.sdgyrodsu = {
        Unit.Description = "Cemuhook DSU server for the Steam Deck Gyroscope";
        Service = {
          ExecStart = "${jovian.legacyPackages.${pkgs.stdenv.hostPlatform.system}.sdgyrodsu}/bin/sdgyrodsu";
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
