{ self, ... }:
{ pkgs, ... }: {

  imports = [ ../../modules/drone ../../modules/oracle-aarch64 ];

  lounge-rocks = {
    oracle-aarch64.enable = true;
    drone = {
      exec-runner.enable = true;
      docker-runner.enable = true;
    };
  };

  networking = { hostName = "oracle-aarch64-1"; };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/mayniklas.keys";
        sha256 = "174dbx0kkrfdfdjswdny25nf7phgcb9k8i6z3rqqcy9l24f8xcp3";
      })
    ];
  };

}
