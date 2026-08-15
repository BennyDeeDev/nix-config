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
    {
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
      systemProfile = import ./profiles/system { inherit home-manager; };
      terminalProfile = import ./profiles/terminal { };
      graphicalProfile = import ./profiles/graphical {
        inherit dgop dms dms-plugin-registry;
      };

      audio = import ./profiles/system/audio.nix { };
      bluetooth = import ./profiles/system/bluetooth.nix { };
      boot = import ./profiles/system/boot.nix { inherit lanzaboote; };
      libvirt = import ./profiles/system/libvirt.nix { };
      networkmanager = import ./profiles/system/networkmanager.nix { };
      podman = import ./profiles/system/podman.nix { };
      printing = import ./profiles/system/printing.nix { };

      sops = import ./modules/sops.nix { inherit sops-nix; };
      nas = import ./modules/nas.nix { };
      container-backup = import ./modules/container-backup.nix { };
      pi5 = import ./modules/pi5.nix { };

      gaming = import ./hosts/desktop/gaming { inherit nix-flatpak; };
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
          modules = [
            systemProfile.nixos
            terminalProfile.nixos
            graphicalProfile.nixos
            audio.nixos
            networkmanager.nixos
            sops.nixos
            ./hosts/vm
            {
              home-manager.users.benjamin.imports = [
                terminalProfile.homeManager
                graphicalProfile.homeManager
                audio.homeManager
                networkmanager.homeManager
              ];
            }
          ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            systemProfile.nixos
            terminalProfile.nixos
            graphicalProfile.nixos
            audio.nixos
            bluetooth.nixos
            boot.nixos
            libvirt.nixos
            networkmanager.nixos
            podman.nixos
            printing.nixos
            sops.nixos
            nas.nixos
            gaming.nixos
            disko.nixosModules.disko
            ./hosts/desktop
            {
              home-manager.users.benjamin.imports = [
                terminalProfile.homeManager
                graphicalProfile.homeManager
                audio.homeManager
                bluetooth.homeManager
                networkmanager.homeManager
                podman.homeManager
                sops.homeManager
                gaming.homeManager
              ];
            }
          ];
        };
        pi5-server = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            systemProfile.nixos
            sops.nixos
            pi5.nixos
            nas.nixos
            container-backup.nixos
            nixos-hardware.nixosModules.raspberry-pi-5
            ./hosts/pi5-server
          ];
        };
        pi5-kiosk = nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            systemProfile.nixos
            sops.nixos
            pi5.nixos
            nixos-hardware.nixosModules.raspberry-pi-5
            ./hosts/pi5-kiosk
          ];
        };
      };
      images.pi5-bootstrap =
        (nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            systemProfile.nixos
            sops.nixos
            pi5.nixos
            ./images/pi5-bootstrap.nix
          ];
        }).config.system.build.sdImage;

      darwinConfigurations.mbp-personal = darwin.lib.darwinSystem {
        modules = [
          systemProfile.darwin
          ./hosts/mbp-personal
          {
            home-manager.users.benjaminderksen.imports = [
              systemProfile.homeManager
              terminalProfile.homeManager
              graphicalProfile.homeManager
              podman.homeManager
              sops.homeManager
            ];
          }
        ];
      };
    };
}
