{
  nixos = {
    imports = [
      (import ./apps.nix).nixos
      (import ./audio.nix).nixos
      (import ./kiosk.nix).nixos
      (import ./waydroid.nix).nixos
      (import ./cec.nix).nixos
    ];
  };
}
