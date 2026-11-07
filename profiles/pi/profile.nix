{
  nixos =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages;
      nix.settings = {
        max-jobs = 1;
        cores = 1;
        trusted-users = [ "benjamin" ];
      };
      system.stateVersion = "26.05";
    };
}
