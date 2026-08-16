{
  nixos =
    { pkgs, ... }:
    {
      # Mainline kernel — cached, fast build. Overrides the nixos-hardware vendor pin.
      boot.kernelPackages = pkgs.linuxPackages;
    };
}
