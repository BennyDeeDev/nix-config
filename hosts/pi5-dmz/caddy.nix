{
  nixos = {
    services.caddy = {
      enable = true;
      openFirewall = true;
      virtualHosts."pi5-dmz.home.arpa" = {
        serverAliases = [
          "10.77.20.10"
          "192.168.178.2"
          "pi5-dmz.fritz.box"
        ];
        extraConfig = ''
          tls internal
          root * ${./www}
          file_server
        '';
      };
    };
  };
}
