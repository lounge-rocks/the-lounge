{ lib, config, ... }:

with lib;

let

  cfg = config.lounge-rocks.woodpecker;

in
{
  imports = [
    ./docker-agent.nix
    ./local-agent.nix
    ./server.nix
  ];

  # options affecting the woodpecker server as well as the woodpecker agents
  options.lounge-rocks.woodpecker = {
    log = mkOption {
      type = types.str;
      default = "info";
      description = "The log level of the woodpecker";
    };
  };

  config = {

    services.woodpecker-server = lib.mkIf config.lounge-rocks.woodpecker.server.enable {
      environment = {
        WOODPECKER_LOG_LEVEL = "${cfg.log}";
      };
    };

    services.woodpecker-agents.agents.exec =
      lib.mkIf config.lounge-rocks.woodpecker.local-agent.enable
        {
          environment = {
            WOODPECKER_LOG_LEVEL = "${cfg.log}";
          };
        };

    services.woodpecker-agents.agents.docker =
      lib.mkIf config.lounge-rocks.woodpecker.docker-agent.enable
        {
          environment = {
            WOODPECKER_LOG_LEVEL = "${cfg.log}";
          };
        };

  };

}
