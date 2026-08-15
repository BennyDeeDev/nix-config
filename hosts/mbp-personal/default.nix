{
  dgop,
  dms,
  dms-plugin-registry,
  home-manager,
  lanzaboote,
  sops-nix,
  ...
}:

let
  baseProfile = import ../../profiles/base { inherit home-manager; };
  systemProfile = import ../../profiles/system { inherit lanzaboote; };
  terminalProfile = import ../../profiles/terminal { };
  graphicalProfile = import ../../profiles/graphical {
    inherit dgop dms dms-plugin-registry;
  };
  sops = import ../../modules/sops.nix { inherit sops-nix; };
in
{ ... }:

{
  imports = [
    baseProfile.darwin
    systemProfile.darwin
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.settings.experimental-features = "nix-command flakes";
  system.primaryUser = "benjaminderksen";

  security.pam.services.sudo_local.touchIdAuth = true;

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

  home-manager.extraSpecialArgs.dotfiles = "/Users/benjaminderksen/Repos/dotfiles";

  users.users.benjaminderksen = {
    name = "benjaminderksen";
    home = "/Users/benjaminderksen";
  };

  home-manager.users.benjaminderksen = {
    imports = [
      systemProfile.homeManager
      terminalProfile.homeManager
      graphicalProfile.homeManager
      sops.homeManager
    ];

    home.stateVersion = "26.05";
    dotfiles.sops.yubikeyIdentity = "AGE-PLUGIN-YUBIKEY-19TEYVQ5ZLFFEFYSGZHTZ3";
    programs.zsh.shellAliases.drs = "sudo darwin-rebuild switch --flake ~/Repos/dotfiles#mbp-personal";
    programs.git.settings.user = {
      name = "BennyDeeDev";
      email = "45900418+BennyDeeDev@users.noreply.github.com";
    };
  };

  system.stateVersion = 5;
}
