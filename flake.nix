{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      home-manager,
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

      homeConfigurations.deck = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {
          nixConfig = "/home/deck/Repos/nix-config";
          flakeHost = "deck";
        };
        modules = [ (import ./hosts/deck inputs).homeManager ];
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
