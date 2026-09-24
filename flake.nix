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
    let
      profiles = import ./profiles inputs;
      desktop = import ./hosts/desktop inputs;
      pi5Server = import ./hosts/pi5-server inputs;
      pi5Kiosk = import ./hosts/pi5-kiosk inputs;
      deck = import ./hosts/deck inputs;
      mbpPersonal = import ./hosts/mbp-personal inputs;
      pi5Bootstrap = import ./images/pi5-bootstrap.nix inputs;
      nixosSystem = nixpkgs.lib.nixosSystem;
      darwinSystem = darwin.lib.darwinSystem;
      homeManagerConfiguration = home-manager.lib.homeManagerConfiguration;
      pkgsX86Linux = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      inherit profiles;

      packages.x86_64-linux = {
        eden-rog-ally-pgo = pkgsX86Linux.callPackage ./packages/eden-rog-ally-pgo.nix { };
        lsfg-vk = pkgsX86Linux.callPackage ./packages/lsfg-vk.nix { };
        eden-steamdeck-pgo = pkgsX86Linux.callPackage ./packages/eden-steamdeck-pgo.nix { };
      };

      nixosConfigurations = {
        desktop = nixosSystem {
          system = "x86_64-linux";
          modules = [ desktop.nixos ];
        };
        pi5-server = nixosSystem {
          system = "aarch64-linux";
          modules = [ pi5Server.nixos ];
        };
        pi5-kiosk = nixosSystem {
          system = "aarch64-linux";
          modules = [ pi5Kiosk.nixos ];
        };
      };

      homeConfigurations.deck = homeManagerConfiguration {
        pkgs = pkgsX86Linux;
        extraSpecialArgs = {
          nixConfig = "/home/deck/Repos/nix-config";
          flakeHost = "deck";
        };
        modules = [ deck.homeManager ];
      };

      darwinConfigurations.mbp-personal = darwinSystem {
        modules = [ mbpPersonal.darwin ];
      };

      images.pi5-bootstrap =
        (nixosSystem {
          system = "aarch64-linux";
          modules = [ pi5Bootstrap.nixos ];
        }).config.system.build.sdImage;
    };
}
