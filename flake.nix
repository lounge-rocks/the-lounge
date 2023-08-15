{
  description = "lounge.rocks - infrastructure";
  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-pipeliner = {
      url = "github:pinpox/woodpecker-flake-pipeliner";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    mayniklas = {
      url = "github:mayniklas/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pinpox = {
      url = "github:pinpox/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pinpox-keys = {
      url = "https://github.com/pinpox.keys";
      flake = false;
    };

    woodpecker-plugin-git = {
      flake = false;
      url = "github:woodpecker-ci/plugin-git";
    };

    pinpox-woodpecker = {
      url = "github:pinpox/woodpecker/nix-runner";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    attic.url = "github:zhaofengli/attic";

    cachix.url = "github:cachix/cachix/v1.6";

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
            { _module.args.pinpox-keys = pinpox-keys; }
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
            { _module.args.pinpox-keys = pinpox-keys; }
            pinpox.nixosModules.openssh
            (import ./machines/woodpecker-server/configuration.nix {
              inherit self;
            })
          ];
        };

      };

    };
}
