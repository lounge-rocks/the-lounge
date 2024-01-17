{ pkgs, lib, config, ... }:
with lib;
let cfg = config.lounge-rocks.woodpecker.server;
in {

  ### TODO: create a common module for NGINX / ACME stuff
  options.lounge-rocks.woodpecker.server = {
    enable = mkEnableOption "enable woodpecker server";
    oci = mkEnableOption "enable woodpecker server in OCI";
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
    services.woodpecker-server = mkIf (!cfg.oci) {
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

    virtualisation.oci-containers = mkIf cfg.oci {
      backend = "docker";
      containers.woodpecker-server = {
        # https://hub.docker.com/r/woodpeckerci/woodpecker-server/tags?page=1&ordering=name
        image = "woodpeckerci/woodpecker-server:v2.1.1";
        volumes = [ "/var/lib/woodpecker-server-oci/:/var/lib/woodpecker/" ];
        environment = {
          WOODPECKER_HOST = "https://${cfg.hostName}";
          WOODPECKER_GITHUB = "true";
          WOODPECKER_OPEN = "true";
          WOODPECKER_ORGS = "lounge-rocks";
          WOODPECKER_ADMIN = "pinpox,MayNiklas";
          WOODPECKER_DEBUG_PRETTY = "true";
        };
        environmentFiles = [ "${config.sops.secrets."woodpecker/server-envfile".path}" ];
        extraOptions = [ "--network=host" ];
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      mkIf config.services.tailscale.enable [ 9000 ];

  };

}
