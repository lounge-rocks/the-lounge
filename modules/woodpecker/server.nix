{ pkgs, lib, config, ... }:
with lib;
let cfg = config.lounge-rocks.woodpecker.server;
in {

  ### TODO: create a common module for NGINX / ACME stuff
  options.lounge-rocks.woodpecker.server = {
    enable = mkEnableOption "enable woodpecker server";
    hostName = mkOption {
      type = types.str;
      default = "build.lounge.rocks";
      description = "The hostname of the attic server";
    };
  };

  config = mkIf cfg.enable {

    lounge-rocks.nginx.enable = true;

    # reverse proxy
    services.nginx.virtualHosts."${cfg.hostName}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
      };
    };

    # woodpecker server
    services.woodpecker-server = {
      enable = true;
      # package = pkgs.lounge-rocks.woodpecker-server;

      # Secrets in env file: WOODPECKER_GITHUB_CLIENT, WOODPECKER_GITHUB_SECRET,
      # WOODPECKER_AGENT_SECRET, WOODPECKER_PROMETHEUS_AUTH_TOKEN
      environmentFile = config.sops.secrets."woodpecker/server-envfile".path;

      environment = {
        WOODPECKER_HOST = "https://${cfg.hostName}";
        WOODPECKER_GITHUB = "true";
        # https://woodpecker-ci.org/docs/administration/server-config/
        # `only allow registration of users, who are members of approved organizations`
        WOODPECKER_OPEN = "true";
        WOODPECKER_ORGS = "lounge-rocks";
        WOODPECKER_ADMIN = "pinpox,MayNiklas"; # Add multiple users as "user1,user2"
        WOODPECKER_CONFIG_SERVICE_ENDPOINT = mkIf config.lounge-rocks.woodpecker.pipeliner.enable "http://127.0.0.1:8585";
        # WOODPECKER_FORGE_TIMEOUT = "30s";
        WOODPECKER_DEBUG_PRETTY = "true";
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      mkIf config.services.tailscale.enable [ 9000 ];

  };

}
