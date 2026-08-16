{
  nixos = { ... }: {
    services.xserver.xkb = {
      layout = "us";
      variant = "";
      options = "compose:ralt";
    };
  };

  homeManager =
    { pkgs, ... }:
    {
      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };
    };
}
