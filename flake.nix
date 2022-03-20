{
  description = "exec runner server";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };
  outputs = { self, ... }@inputs:
    with inputs;
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {

        oracle-aarch64-1 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ (import ./machines/oracle-aarch64-1/configuration.nix { inherit self; }) ];
        };
        
      };
    };
}
