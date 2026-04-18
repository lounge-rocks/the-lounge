{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.lounge-rocks.woodpecker.docker-agent;
in
{

  options.lounge-rocks.woodpecker.docker-agent = {
    enable = mkEnableOption "enable docker woodpecker agent";
    envFile = mkOption {
      type = types.path;
      description = "Path to the environment file with woodpecker agent secrets";
    };
  };

  config = mkIf cfg.enable {

    services.woodpecker-agents = {
      agents.docker = {
        enable = true;
        # package = pkgs.lounge-rocks.woodpecker-agent;
        environment = {
          WOODPECKER_SERVER = "100.65.12.86:9000";
          WOODPECKER_MAX_WORKFLOWS = "1";
          WOODPECKER_BACKEND = "docker";
          WOODPECKER_FILTER_LABELS = "type=docker";
          WOODPECKER_HEALTHCHECK = "false";
        };
        # Secrets in envfile: WOODPECKER_AGENT_SECRET
        environmentFile = [ cfg.envFile ];
        extraGroups = [ "docker" ];
      };
    };

    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    systemd.services.woodpecker-agent-docker = {
      after = [ "docker.socket" ];
      restartIfChanged = false;
      serviceConfig = {
        BindPaths = [ "/var/run/docker.sock" ];
      };
    };

  };
}
