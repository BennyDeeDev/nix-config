{ inputs, ... }:

{
  nixos = { ... }:
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
      services.flatpak.enable = true;
    };

  homeManager = { ... }:
    {
      imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
      services.flatpak.update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
}
