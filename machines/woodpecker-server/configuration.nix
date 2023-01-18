{ self, ... }:
{ pkgs, pinpox-woodpecker, config, ... }: {



  sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  # sops.secrets."minio/env" = {
  #   restartUnits = [ "minio.service" ];
  # };
  # rootCredentialsFile = config.sops.secrets."minio/env".path;


  services.woodpecker-server = {

    package = pinpox-woodpecker.packages.x86_64-linux.woodpecker-server;
    enable = true;
    rootUrl = "https://build.0cx.de";
    httpPort = 3030;
    admins = "pinpox";
    database = {
      type = "postgres";
    };
    giteaClientIdFile = "${config.sops.screts."woodpecker/gitea-client-id".path}";
    giteaClientSecretFile = "${config.sops.secrets."woodpecker/gitea-client-secret".path}";
    agentSecretFile = "${config.sops.secrets."woodpecker/agent-secret".path}";
  };

  services.woodpecker-agent = {
    enable = true;
    backend = "local";
    maxProcesses = 5;
    agentSecretFile = "${config.sops.secrets."woodpecker/agent-secret".path}";
    package = pinpox-woodpecker.packages.x86_64-linux.woodpecker-agent;
  };

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
