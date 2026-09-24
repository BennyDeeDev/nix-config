{
  homeManager =
    { pkgs, ... }:
    {
      home.sessionVariables.NIXOS_OZONE_WL = "1";
      programs.brave.enable = true;

      home.packages = with pkgs; [
        spotify
        nerd-fonts.hack
        keepassxc
      ];
    };
}
