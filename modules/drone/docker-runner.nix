{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lounge-rocks.drone.docker-runner;
in {

  options.lounge-rocks.drone.docker-runner = { enable = mkEnableOption "enable drone-docker-runner"; };

  config = mkIf cfg.enable {

    virtualisation.docker = {
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    virtualisation.oci-containers.containers = {
      drone-runner = {
        autoStart = true;
        image = "drone/drone-runner-docker:1";

        environment = {
          DRONE_RPC_PROTO = "https";
          DRONE_RPC_HOST = "drone.lounge.rocks";
          DRONE_RUNNER_CAPACITY = "8";
          DRONE_RUNNER_NAME = "drone-runner-ARM";
        };

        extraOptions =
          [ "--network=host" "--env-file=/var/src/secrets/drone-ci/envfile" ];

        volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
      };
    };
  };

}