{
  homeManager =
    { lib, pkgs, ... }:
    {
      programs = {
        brave.enable = true;
        google-chrome.enable = true;

        # Keep KeePassXC browser integration disabled; the Home Manager module
        # generates a broken native-messaging manifest on macOS.
        # keepassxc.enable = true;
      };

      home.packages = [
        pkgs.spotify
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.hack
        pkgs.keepassxc
      ];
    };
}
