{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      darwin,
      disko,
      lanzaboote,
      sops-nix,
      nixos-hardware,
      nix-flatpak,
      dms,
      dgop,
      dms-plugin-registry,
      ...
    }:
    let
      profileArgs = {
        inherit inputs;
        lib = nixpkgs.lib;
        repoRoot = ./.;
      };
      systemProfile = import ./profiles/system profileArgs;
      workstationProfile = import ./profiles/workstation (
        profileArgs // { inherit systemProfile; }
      );
      dotfiles = "/home/benjamin/Repos/dotfiles";
      homeManagerModule = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
        home-manager.extraSpecialArgs = {
          inherit
            dms
            dgop
            dms-plugin-registry
            nix-flatpak
            dotfiles
            ;
        };
      };
      darwinHomeManagerModule = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
        home-manager.extraSpecialArgs = {
          inherit
            dms
            dgop
            dms-plugin-registry
            nix-flatpak
            ;
        };
      };
    in
    {
      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit workstationProfile; };
          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            homeManagerModule
            ./nix/hosts/vm
          ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs workstationProfile;
            repoRoot = ./.;
          };
          modules = [
            disko.nixosModules.disko
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
            nix-flatpak.nixosModules.nix-flatpak
            home-manager.nixosModules.home-manager
            homeManagerModule
            ./nix/hosts/desktop
          ];
        };
        pi5-server = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            nixos-hardware.nixosModules.raspberry-pi-5
            sops-nix.nixosModules.sops
            ./nix/hosts/pi5-server
          ];
        };
        pi5-kiosk = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            nixos-hardware.nixosModules.raspberry-pi-5
            sops-nix.nixosModules.sops
            ./nix/hosts/pi5-kiosk
          ];
        };
      };
      images.pi5-bootstrap =
        (nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            sops-nix.nixosModules.sops
            ./nix/images/pi5-bootstrap.nix
          ];
        }).config.system.build.sdImage;

      darwinConfigurations.mbp-personal = darwin.lib.darwinSystem {
        specialArgs = { inherit workstationProfile; };
        modules = [
          home-manager.darwinModules.home-manager
          darwinHomeManagerModule
          ./hosts/mbp-personal/default.nix
        ];
      };
    };
}
