{ self, ... }:
{ pkgs, ... }: {

  lounge-rocks = {
    oracle-aarch64.enable = true;
    drone = {
      exec-runner.enable = true;
      docker-runner = {
        enable = true;
        runner_capacity = "12";
        runner_name = "oracle-aarch64-runner-1";
      };
    };
    nix-build-signature.enable = true;
    nix-common.enable = true;
    tailscale.enable = true;
  };

  networking = { hostName = "oracle-aarch64-runner-1"; };

  mayniklas = { user.root.enable = true; };

  system.stateVersion = "22.05";

}
