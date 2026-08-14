{ inputs, ... }:

{
  nixos =
    { ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      time.timeZone = "Europe/Berlin";

      i18n.defaultLocale = "en_US.UTF-8";
      i18n.extraLocaleSettings = {
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

      console.keyMap = "us";

      programs.zsh.enable = true;
      programs.git.enable = true;
      programs.vim.enable = true;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs.dotfiles = "/home/benjamin/Repos/dotfiles";
      };
    };
}
