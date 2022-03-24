{
  description = "exec runner server";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pinpox.url = "github:pinpox/nixos";
    pinpox.inputs.nixpkgs.follows = "nixpkgs";

  sops-nix.url = github:Mic92/sops-nix;
  sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # mayniklas.url = "github:mayniklas/nixos";
    # mayniklas.inputs.nixpkgs.follows = "nixpkgs";

  };
  outputs = { self, ... }@inputs:
    with inputs;
    let
      # seems like we don't need that line?
      # system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        minio-host = nixpkgs.lib.nixosSystem {
          # system = "test${(builtins.readFile ./machines/minio-host/arch)}";
          # system = "aarch64-linux";
          system = import ./machines/minio-host/arch.nix;
          modules = builtins.attrValues self.nixosModules ++ [
            pinpox.nixosModules.openssh
            sops-nix.nixosModules.sops
            (import ./machines/minio-host/configuration.nix { inherit self; })
          ];
        };

        oracle-aarch64-runner-1 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = builtins.attrValues self.nixosModules ++ [
            (import ./machines/oracle-aarch64-runner-1/configuration.nix {
              inherit self;
            })
          ];
        };

        netcup-x86-runner-1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = builtins.attrValues self.nixosModules ++ [
            (import ./machines/netcup-x86-runner-1/configuration.nix {
              inherit self;
            })
          ];
        };

      };

      nixosModules = builtins.listToAttrs (map (x: {
        name = x;
        value = import (./modules + "/${x}");
      }) (builtins.attrNames (builtins.readDir ./modules)));

    };
}
