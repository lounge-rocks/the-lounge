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

    # reverse proxy
    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      # tmp fix for attic:
      # should be set only for attic!
      clientMaxBodySize = "512m";
      recommendedProxySettings = true;

      commonHttpConfig = ''
        server_names_hash_bucket_size 128;
        proxy_headers_hash_max_size 1024;
        proxy_headers_hash_bucket_size 256;
      '';

      virtualHosts."${cfg.hostName}" = {
        addSSL = true;
        enableACME = true;
        locations."/" = { proxyPass = "http://127.0.0.1:8000"; };
      };
    };

    # ACME config
    security.acme.acceptTerms = true;
    security.acme.defaults.email = "acme@pablo.tools";

    # woodpecker server
    services.woodpecker-server = {
      enable = true;
      package = pkgs.lounge-rocks.woodpecker-server;

      # Secrets in env file: WOODPECKER_GITHUB_CLIENT, WOODPECKER_GITHUB_SECRET,
      # WOODPECKER_AGENT_SECRET, WOODPECKER_PROMETHEUS_AUTH_TOKEN
      environmentFile = config.sops.secrets."woodpecker/server-envfile".path;

      environment = {
        WOODPECKER_HOST = "https://${cfg.hostName}";
        WOODPECKER_OPEN = "false";
        WOODPECKER_GITHUB = "true";
        WOODPECKER_ADMIN = "pinpox,MayNiklas"; # Add multiple users as "user1,user2"
        WOODPECKER_ORGS = "lounge-rocks";
        WOODPECKER_CONFIG_SERVICE_ENDPOINT = mkIf config.lounge-rocks.woodpecker.pipeliner.enable "http://127.0.0.1:8585";
      };
    };

    networking.firewall.allowedTCPPorts = [ 443 80 ];

  };

}
