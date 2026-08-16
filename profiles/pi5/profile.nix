{
  nixos =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages;
      nix.settings.trusted-users = [ "benjamin" ];
      system.stateVersion = "26.05";
    };
}
