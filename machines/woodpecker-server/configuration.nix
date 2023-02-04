{ self, ... }:
{ pkgs, pinpox-woodpecker, config, ... }: {


  nix.settings.allowed-users = [ config.services.woodpecker-agent.user "woodpecker-agent" ];

  sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  sops.secrets = {
    # "woodpecker/gitea-client-id".restartUnits = [ "woodpecker-server.service" ];
    # "woodpecker/gitea-client-secret".restartUnits = [ "woodpecker-server.service" ];
    "woodpecker/server-envfile".restartUnits = [ "woodpecker-server.service" ];

    "woodpecker/agent-secret".restartUnits = [ "woodpecker-agent.service" "woodpecker-server.service" ];
  };
  # rootCredentialsFile = config.sops.secrets."minio/env".path;

  networking.firewall.allowedTCPPorts = [ 443 80 ];

  services.woodpecker-server = {
    # giteaUrl = "https://git.0cx.de";

    useGitea = false;

    package = pinpox-woodpecker.packages.x86_64-linux.woodpecker-server;
    enable = true;
    rootUrl = "https://build.lounge.rocks";
    httpPort = 3030;
    admins = "pinpox";
    database = {
      type = "sqlite3";
    };
    # giteaClientIdFile = "${config.sops.screts."woodpecker/gitea-client-id".path}";
    # giteaClientSecretFile = "${config.sops.secrets."woodpecker/gitea-client-secret".path}";
    agentSecretFile = "${config.sops.secrets."woodpecker/agent-secret".path}";
    environmentFile = "${config.sops.secrets."woodpecker/server-envfile".path}";
  };

  services.woodpecker-agent = {
    enable = true;
    backend = "local";
    maxProcesses = 5;
    agentSecretFile = "${config.sops.secrets."woodpecker/agent-secret".path}";

    package = pinpox-woodpecker.packages.x86_64-linux.woodpecker-agent;
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@pablo.tools";

  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "128m";

    virtualHosts = {

      "build.lounge.rocks" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = { proxyPass = "http://127.0.0.1:3030"; };
      };

    };
  };

  # General stuff

  lounge-rocks = {
    hetzner-x86.enable = true;
    nix-common.enable = true;
  };

  mayniklas = { user.root.enable = true; };
  pinpox = { services.openssh.enable = true; };

  networking = {
    hostName = "woodpecker-server";
    interfaces.ens3 = {
      ipv6.addresses = [{
        address = "2a01:4f8:1c1b:95a::";
        prefixLength = 64;
      }];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };

  system.stateVersion = "22.05";

}


