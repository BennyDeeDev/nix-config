{
  gaming,
  profiles,
  sops,
  windows,
}:

let
  apps = import ../../modules/apps.nix;
  ghostty = import ../../modules/ghostty.nix;
  myHomeManagerProfile = import ../../modules/home-manager-profile.nix;
  vscode = import ../../modules/vscode.nix;
in

{
  nixos = {
    home-manager = {
      extraSpecialArgs = {
        nixConfig = "/home/benjamin/Repos/nix-config";
        flakeHost = "desktop";
      };
      users.benjamin =
        { ... }:
        {
          imports = [
            profiles.desktop.homeManager
            profiles.terminal.homeManager
            apps.homeManager
            ghostty.homeManager
            myHomeManagerProfile.homeManager
            vscode.homeManager
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
  };
}
