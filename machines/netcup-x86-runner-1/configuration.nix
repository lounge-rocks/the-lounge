{ self, ... }:
{ pkgs, ... }: {

  lounge-rocks = {
    netcup-x86.enable = true;
    # drone = {
    #   exec-runner.enable = true;
    #   docker-runner.enable = true;
    # };
    nix-build-signature.enable = true;
  };

  networking = { hostName = "netcup-x86-runner-1"; };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/mayniklas.keys";
        sha256 = "174dbx0kkrfdfdjswdny25nf7phgcb9k8i6z3rqqcy9l24f8xcp3";
      })
    ];
  };

}
