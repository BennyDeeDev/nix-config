{
  homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        spotify
        nerd-fonts.jetbrains-mono
        nerd-fonts.hack
        keepassxc
      ];
    };
}
