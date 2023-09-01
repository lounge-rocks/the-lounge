{ self, ... }:
{ pkgs, lib, config, ... }: {

  lounge-rocks = {
    cloud-provider.netcup.enable = true;
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
    users.MayNiklas.root = true;
  };

  lollypops.deployment.ssh = {
    user = "root";
    host = "${config.networking.fqdn}";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking = {
    domain = "lounge.rocks";
    hostName = "netcup-x86-runner-1";
    interfaces.ens3 = {
      ipv6.addresses = [{
        address = "2a03:4000:60:ece::";
        prefixLength = 64;
      }];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
