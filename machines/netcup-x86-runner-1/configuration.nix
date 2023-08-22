{ self, ... }:
{ pkgs, lib, ... }: {

  lounge-rocks = {
    cloud-provider = {
      enable = true;
      netcup.enable = true;
    };
    drone = {
      exec-runner.enable = true;
      docker-runner = {
        enable = true;
        runner_capacity = "2";
        runner_name = "netcup-x86-runner-1";
      };
    };
    nix-build-signature.enable = true;
    nix-common.enable = true;
    tailscale.enable = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking = {
    hostName = "netcup-x86-runner-1";
    interfaces.ens3 = {
      ipv6.addresses = [{
        address = "2a03:4000:60:ece::";
        prefixLength = 64;
      }];
    };
  };

  mayniklas = { user.root.enable = true; };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
