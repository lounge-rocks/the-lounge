{
  description = "exec runner server";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };
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

        oracle-aarch64-runner-1 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = builtins.attrValues self.nixosModules ++ [
            (import ./machines/oracle-aarch64-runner-1/configuration.nix {
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
