{ self, ... }:
{ pkgs, ... }: {
  imports = [
    ./modules/oracle-aarch64
    ./modules/drone/exec-runner.nix
    ./modules/drone/docker-runner.nix
  ];

  networking = { hostName = "nixos"; };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/mayniklas.keys";
        sha256 = "174dbx0kkrfdfdjswdny25nf7phgcb9k8i6z3rqqcy9l24f8xcp3";
      })
    ];
  };

}
