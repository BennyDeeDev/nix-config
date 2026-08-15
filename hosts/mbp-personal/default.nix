inputs@{
  sops-nix,
  ...
}:

let
  profiles = import ../../profiles inputs;
  sops = import ../../modules/sops.nix { inherit sops-nix; };
in
{ ... }:

{
  imports = [
    profiles.base.darwin
    profiles.system.darwin
    profiles.graphical.darwin
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "benjaminderksen";

  homebrew = {
    brews = [ "mas" ];
    masApps = {
      Xcode = 497799835;
      "Final Cut Pro" = 424389933;
    };
    casks = [
      "google-drive"
      "ledger-wallet"
      "obs"
      "raspberry-pi-imager"
      "teamviewer"
      "vlc"
    ];
  };

  home-manager = {
    extraSpecialArgs.dotfiles = "/Users/benjaminderksen/Repos/dotfiles";
    users.benjaminderksen = {
      imports = [
        profiles.system.homeManager
        profiles.terminal.homeManager
        profiles.graphical.homeManager
        sops.homeManager
      ];

      home.stateVersion = "26.05";
      dotfiles.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-19TEYVQ5ZLFFEFYSGZHTZ3";
      programs = {
        zsh.shellAliases.drs = "sudo darwin-rebuild switch --flake ~/Repos/dotfiles#mbp-personal";
        git.settings.user = {
          name = "BennyDeeDev";
          email = "45900418+BennyDeeDev@users.noreply.github.com";
        };
      };
    };
  };

  users.users.benjaminderksen = {
    name = "benjaminderksen";
    home = "/Users/benjaminderksen";
  };

  system.stateVersion = 5;
}
