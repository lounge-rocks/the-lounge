{
  description = "lounge.rocks - infrastructure";
  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    pinpox.url = "github:pinpox/nixos";
    pinpox.inputs.nixpkgs.follows = "nixpkgs";
    pinpox.inputs.flake-utils.follows = "flake-utils";

    pinpox-keys = {
      url = "https://github.com/pinpox.keys";
      flake = false;
    };

    mayniklas.url = "github:mayniklas/nixos";
    mayniklas.inputs.nixpkgs.follows = "nixpkgs";
    mayniklas.inputs.flake-utils.follows = "flake-utils";

    cachix.url = "github:cachix/cachix/v1.2";

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
    in
    {
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

        hetzner-x86-runner-1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { flake-self = self; } // inputs;
          modules = builtins.attrValues self.nixosModules ++ [
            mayniklas.nixosModules.user
            (import ./machines/hetzner-x86-runner-1/configuration.nix {
              inherit self;
            })
          ];
        };

        woodpecker-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { flake-self = self; } // inputs;
          modules = builtins.attrValues self.nixosModules ++ [
            mayniklas.nixosModules.user
            { _module.args.pinpox-keys = pinpox-keys; }
            pinpox.nixosModules.openssh
            (import ./machines/woodpecker-server/configuration.nix {
              inherit self;
            })
          ];
        };

      };

      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};

      in
      rec {

        # Use nixpkgs-fmt for `nix fmt'
        formatter = pkgs.nixpkgs-fmt;

        packages = flake-utils.lib.flattenTree rec {

          s3uploader = pkgs.writeShellScriptBin "s3uploader" ''
            for path in $(nix-store -qR $1); do
                # echo $path
              sigs=$(nix path-info --sigs --json $path | ${pkgs.jq}/bin/jq 'try .[].signatures[]')
              if [[ $sigs == *"cache.lounge.rocks"* ]]
              then
                echo "add $path to upload.list"
                echo $path >> upload.list
              fi
            done
            cat upload.list | uniq > upload
            nix copy --to 's3://nix-cache?scheme=https&region=eu-central-1&endpoint=s3.lounge.rocks&compression=zstd&parallel-compression=true' $(cat upload)
          '';
        };

        apps = {
          s3uploader = flake-utils.lib.mkApp {
            drv = packages.s3uploader;
          };
        };
      });
}
