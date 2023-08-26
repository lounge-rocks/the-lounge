{ lib, config, ... }:
with lib;
let cfg = config.lounge-rocks.woodpecker.docker-agent; in
{

  options.lounge-rocks.woodpecker.docker-agent = {
    enable = mkEnableOption "enable docker woodpecker agent";
  };

  config = mkIf cfg.enable {

    services.woodpecker-agents = {
      agents.docker = {
        enable = true;
        environment = {
          WOODPECKER_SERVER = "127.0.0.1:9000";
          WOODPECKER_MAX_WORKFLOWS = "1";
          WOODPECKER_BACKEND = "docker";
          WOODPECKER_FILTER_LABELS = "type=docker";
          WOODPECKER_HEALTHCHECK = "false";
        };
        # Secrets in envfile: WOODPECKER_AGENT_SECRET
        environmentFile = [ config.sops.secrets."woodpecker/agent-envfile".path ];
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
      serviceConfig = { BindPaths = [ "/var/run/docker.sock" ]; };
    };

  };
}
