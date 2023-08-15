{
  description = "lounge.rocks - infrastructure";
  inputs = {

    # https://github.com/nixos/nixpkgs
    # Nix Packages collection & NixOS
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    ### User repositories (mainly used for users / keys)

    # https://github.com/mayniklas/nixos
    # MayNiklas NixOS modules
    mayniklas = {
      url = "github:mayniklas/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/pinpox/nixos
    # pinpox NixOS modules
    pinpox = {
      url = "github:pinpox/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Tools for managing NixOS

    # https://github.com/nix-community/disko
    # Format disks with nix-config 
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/Mic92/sops-nix
    # Atomic secret provisioning for NixOS based on sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Applications from outside nixpkgs

    # https://github.com/zhaofengli/attic
    # Multi-tenant Nix Binary Cache
    attic = {
      url = "github:zhaofengli/attic";
    };

    # https://github.com/cachix/cachix
    # Command line client for Nix binary cache hosting
    cachix = {
      url = "github:cachix/cachix/v1.6";
    };

    # https://github.com/pinpox/woodpecker-flake-pipeliner
    # Woodpecker configuration Service to dynamically generate pipelines from nix flakes
    flake-pipeliner = {
      url = "github:pinpox/woodpecker-flake-pipeliner";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = { self, ... }@inputs:
    with inputs;
    let
      supportedSystems =
        [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

      overlays.default =
        (final: prev: { lounge-rocks = import ./pkgs { inherit pkgs; }; });

      packages = forAllSystems
        (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });

      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

      nixosConfigurations = {
        stuart = nixpkgs.lib.nixosSystem {
          system = import ./machines/stuart/arch.nix;
          specialArgs = { flake-self = self; } // inputs;
          modules = builtins.attrValues self.nixosModules ++ [
            mayniklas.nixosModules.user
            pinpox.nixosModules.openssh
            sops-nix.nixosModules.sops
            (import ./machines/stuart/configuration.nix { inherit self; })
          ];
        };

        oracle-aarch64-runner-1 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { flake-self = self; } // inputs;
          modules = builtins.attrValues self.nixosModules ++ [
            mayniklas.nixosModules.user
            (import ./machines/oracle-aarch64-runner-1/configuration.nix {
              inherit self;
            })
          ];
        };

        netcup-x86-runner-1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { flake-self = self; } // inputs;
          modules = builtins.attrValues self.nixosModules ++ [
            mayniklas.nixosModules.user
            (import ./machines/netcup-x86-runner-1/configuration.nix {
              inherit self;
            })
          ];
        };

        woodpecker-server = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { flake-self = self; } // inputs;
          modules = builtins.attrValues self.nixosModules ++ [
            mayniklas.nixosModules.user
            sops-nix.nixosModules.sops
            pinpox.nixosModules.openssh
            (import ./machines/woodpecker-server/configuration.nix {
              inherit self;
            })
          ];
        };

      };

    };
}
