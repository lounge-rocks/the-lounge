{ self, ... }:
{ pkgs, ... }: {

  lounge-rocks = {
    netcup-x86.enable = true;
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

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/mayniklas.keys";
        sha256 = "174dbx0kkrfdfdjswdny25nf7phgcb9k8i6z3rqqcy9l24f8xcp3";
      })
    ];
  };

}
