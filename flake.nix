{
  description = "lounge.rocks - infrastructure";
  inputs = {

    # https://git.clan.lol/clan/clan-core
    # Clan framework
    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    };

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

    ### Applications from outside nixpkgs

    # https://github.com/lounge-rocks/crab_share
    # upload files to an S3 bucket and generate a shareable link.
    crab_share = {
      url = "github:lounge-rocks/crab_share";
    };

    # https://github.com/pinpox/woodpecker-flake-pipeliner
    # Woodpecker configuration Service to dynamically generate pipelines from nix flakes
    flake-pipeliner = {
      url = "github:pinpox/woodpecker-flake-pipeliner";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # https://github.com/Mic92/nix-fast-build
    # speed-up your evaluation and building process.
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
    };

    treefmt-nix.follows = "clan-core/treefmt-nix";

  };
  outputs =
    {
      self,
      clan-core,
      nixpkgs,
      treefmt-nix,
      ...
    }@inputs:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        }
      );

      clan = clan-core.lib.clan {
        inherit self;
        imports = [ ./clan.nix ];
        specialArgs = {
          flake-self = self;
          inherit self inputs;
        }
        // builtins.removeAttrs inputs [ "self" ];
      };
    in
    {
      inherit (clan.config) nixosConfigurations nixosModules clanInternals;
      clan = clan.config;

      formatter = forAllSystems (
        system:
        (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        }).config.build.wrapper
      );

      overlays.default = final: prev: (import ./pkgs inputs) final prev;

      packages = forAllSystems (system: {
        woodpecker-pipeline = nixpkgsFor.${system}.callPackage ./pkgs/woodpecker-pipeline {
          inputs = inputs;
          flake-self = self;
        };
        inherit (nixpkgsFor.${system}.lounge-rocks)
          s3uploader
          upload-nixos-iso
          ;
      });

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [
            clan-core.packages.${system}.clan-cli
          ];
        };
      });

    };
}
