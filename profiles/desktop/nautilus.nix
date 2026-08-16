{
  nixos = { ... }: {
    services.gvfs.enable = true;
  };

  homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nautilus
        ffmpegthumbnailer
      ];
    };
}
