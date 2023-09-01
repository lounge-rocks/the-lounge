{
  description = "lounge.rocks - infrastructure";
  inputs = {

    # https://github.com/nixos/nixpkgs
    # Nix Packages collection & NixOS
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
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

    # https://github.com/pinpox/lollypops/
    # NixOS Deployment Tool
    lollypops = {
      url = "github:pinpox/lollypops";
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
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });
    in
    {
      formatter = forAllSystems
        (system: nixpkgsFor.${system}.nixpkgs-fmt);

      overlays.default = final: prev:
        (import ./pkgs inputs) final prev;

      # TODO:
      # is is possible to inherit all packages from nixpkgsFor.${system}.lounge-rocks?
      # this would be much cleaner since we would not need to list all packages here
      packages = forAllSystems (system: {
        woodpecker-pipeline = nixpkgsFor.${system}.callPackage ./pkgs/woodpecker-pipeline {
          inputs = inputs;
          flake-self = self;
        };
        inherit (nixpkgsFor.${system}.lounge-rocks)
          s3uploader
          woodpecker-agent
          woodpecker-cli
          woodpecker-server
          ;
      });

      apps = forAllSystems (system: {
        # nix run .\#lollypops -- --list-all
        # nix run .\#lollypops -- --parallel woodpecker-agent-aarch64-1 woodpecker-agent-x86-1 woodpecker-server 
        lollypops = lollypops.apps.${system}.default { configFlake = self; };
      });

      nixosModules = builtins.listToAttrs (map
        (x: {
          name = x;
          value = import (./modules + "/${x}");
        })
        (builtins.attrNames (builtins.readDir ./modules)));

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs (map
        (x: {
          name = x;
          value = nixpkgs.lib.nixosSystem {

            # Make inputs and the flake itself accessible as module parameters.
            # Technically, adding the inputs is redundant as they can be also
            # accessed with flake-self.inputs.X, but adding them individually
            # allows to only pass what is needed to each module.
            specialArgs = { flake-self = self; } // inputs;

            modules = builtins.attrValues self.nixosModules ++ [
              lollypops.nixosModules.lollypops
              sops-nix.nixosModules.sops
              (import "${./.}/machines/${x}/configuration.nix" { inherit self; })
            ];

          };
        })
        (builtins.attrNames (builtins.readDir ./machines)));

    };
}
