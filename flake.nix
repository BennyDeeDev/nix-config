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
      moduleSet = import ./modules profileArgs;
      systemProfile = import ./profiles/system profileArgs;
      workstationProfile = import ./profiles/workstation (profileArgs // { inherit systemProfile; });
      specialArgs = {
        inherit
          inputs
          moduleSet
          systemProfile
          workstationProfile
          ;
        repoRoot = ./.;
      };
    in
    {
      formatter = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ] (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      nixosConfigurations = {
        vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/vm ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ ./hosts/desktop ];
        };
        pi5-server = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [ ./hosts/pi5-server ];
        };
        pi5-kiosk = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [ ./hosts/pi5-kiosk ];
        };
      };
      images.pi5-bootstrap =
        (nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          inherit specialArgs;
          modules = [ ./images/pi5-bootstrap.nix ];
        }).config.system.build.sdImage;

      darwinConfigurations.mbp-personal = darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [ ./hosts/mbp-personal ];
      };
    };
}
