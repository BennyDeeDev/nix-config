{ nix-flatpak }:

{
  nixos =
    { ... }:
    {
      imports = [ nix-flatpak.nixosModules.nix-flatpak ];
      services.flatpak.enable = true;
    };

  homeManager =
    { ... }:
    {
      imports = [ nix-flatpak.homeManagerModules.nix-flatpak ];
      services.flatpak.update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
}
