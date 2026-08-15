{
  gaming,
  profiles,
  sops,
  windows,
}:

{ ... }:

{
  home-manager = {
    extraSpecialArgs = {
      dotfiles = "/home/benjamin/Repos/dotfiles";
      flakeHost = "desktop";
    };
    users.benjamin =
      { ... }:
      {
        imports = [
          profiles.system.homeManager
          profiles.terminal.homeManager
          profiles.graphical.homeManager
          sops.homeManager
          gaming.homeManager
          windows.homeManager
        ];

        sops.defaultSopsFile = ../../secrets/desktop.yaml;
        my.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT";
        home = {
          username = "benjamin";
          homeDirectory = "/home/benjamin";
          stateVersion = "25.11";
        };
      };
  };
}
