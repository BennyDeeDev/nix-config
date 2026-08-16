{
  homeManager =
    { pkgs, ... }:
    {
      programs = {
        brave.enable = true;
        google-chrome.enable = true;
        keepassxc.enable = true;
      };

      home.packages = [
        pkgs.spotify
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.hack
      ];
    };
}
