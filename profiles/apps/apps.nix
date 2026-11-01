{
  homeManager =
    { pkgs, ... }:
    {
      home.sessionVariables.NIXOS_OZONE_WL = "1";

      home.packages = with pkgs; [
        google-chrome
        spotify
        nerd-fonts.hack
        keepassxc
      ];
    };
}
