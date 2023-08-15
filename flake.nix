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

    # for some reason this needs to be present for the pinpox keys module to work
    pinpox-keys = {
      url = "https://github.com/pinpox.keys";
      flake = false;
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

            system = import ./machines/${x}/arch.nix;

            modules = builtins.attrValues self.nixosModules ++ [
              mayniklas.nixosModules.user
              pinpox.nixosModules.openssh
              sops-nix.nixosModules.sops
              (import ./machines + "/${x}/configuration.nix" { inherit self; })
              {
                nixpkgs.hostPlatform = nixpkgs.lib.mkDefault import ./machines/${x}/arch.nix;
              }
            ];

          };
        })
        (builtins.attrNames (builtins.readDir ./machines)));

    };
}
