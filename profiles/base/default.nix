{
  home-manager,
  sops-nix,
}:

let
  sops = import ../../modules/sops.nix { inherit sops-nix; };
  common = {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
in
{
  nixos = {
    imports = [
      common
      home-manager.nixosModules.home-manager
      sops.nixos
    ];

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    zramSwap.enable = true;

    time.timeZone = "Europe/Berlin";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };
    };

    console.keyMap = "us";

    programs = {
      zsh.enable = true;
      git.enable = true;
      vim = {
        enable = true;
        defaultEditor = true;
      };
    };
  };

  darwin = {
    imports = [
      common
      home-manager.darwinModules.home-manager
    ];

    nix.gc = {
      automatic = true;
      # nix-darwin uses launchd calendar fields instead of NixOS's systemd calendar string.
      interval = {
        Weekday = 1;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };
}
