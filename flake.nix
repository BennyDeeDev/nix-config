{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/v1.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter/v1.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      darwin,
      ...
    }:
    {
      profiles = import ./profiles inputs;

      formatter = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ] (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ (import ./hosts/desktop inputs).nixos ];
        };
        pi5-server = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ (import ./hosts/pi5-server inputs).nixos ];
        };
        pi5-kiosk = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ (import ./hosts/pi5-kiosk inputs).nixos ];
        };
      };

      darwinConfigurations.mbp-personal = darwin.lib.darwinSystem {
        modules = [ (import ./hosts/mbp-personal inputs).darwin ];
      };

      images.pi5-bootstrap =
        (nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ (import ./images/pi5-bootstrap.nix inputs).nixos ];
        }).config.system.build.sdImage;
    };
}
