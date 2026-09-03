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
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
      url = "github:AvengeMedia/DankMaterialShell/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter";
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
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          lib,
          system,
          pkgs,
          ...
        }:
        let
          mkPiBootstrapImage =
            image:
            (inputs.nixpkgs.lib.nixosSystem {
              modules = [
                {
                  nixpkgs.hostPlatform.system = "aarch64-linux";
                  nixpkgs.buildPlatform.system = system;
                }
                image
              ];
            }).config.system.build.sdImage;
        in
        {
          formatter = pkgs.nixfmt-tree;

          packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            pi5-bootstrap-mainline = mkPiBootstrapImage (import ./images/pi5-bootstrap-mainline.nix inputs)
              .nixos;
            pi5-bootstrap-rpi = mkPiBootstrapImage (import ./images/pi5-bootstrap-rpi.nix inputs).nixos;
          };
        };

      flake =
        let
          mkPiSystem =
            host: buildSystem:
            inputs.nixpkgs.lib.nixosSystem {
              modules = [
                {
                  nixpkgs.hostPlatform.system = "aarch64-linux";
                  nixpkgs.buildPlatform.system = buildSystem;
                }
                (import host inputs).nixos
              ];
            };
        in
        {
          profiles = import ./profiles inputs;

          nixosConfigurations = {
            desktop = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [ (import ./hosts/desktop inputs).nixos ];
            };

            pi5-server = mkPiSystem ./hosts/pi5-server "aarch64-linux";
            pi5-server-cross = mkPiSystem ./hosts/pi5-server "x86_64-linux";

            pi5-kiosk = mkPiSystem ./hosts/pi5-kiosk "aarch64-linux";
            pi5-kiosk-cross = mkPiSystem ./hosts/pi5-kiosk "x86_64-linux";

            pi5-tv = mkPiSystem ./hosts/pi5-tv "aarch64-linux";
            pi5-tv-cross = mkPiSystem ./hosts/pi5-tv "x86_64-linux";
          };

          darwinConfigurations.mbp-personal = inputs.darwin.lib.darwinSystem {
            modules = [ (import ./hosts/mbp-personal inputs).darwin ];
          };
        };
    };
}
