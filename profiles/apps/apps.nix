{
  homeManager =
    { pkgs, ... }:
    {
      home.sessionVariables.NIXOS_OZONE_WL = "1";

      home.packages = with pkgs; [
        spotify
        nerd-fonts.hack
        keepassxc
      ];
    };
}
