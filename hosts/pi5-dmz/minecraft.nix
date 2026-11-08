{
  nixos = {
    services.minecraft-server = {
      enable = true;
      eula = true;
      declarative = true;
      openFirewall = true;
      serverProperties = {
        "pause-when-empty-seconds" = 60;
        "white-list" = false;
      };
    };
  };
}
