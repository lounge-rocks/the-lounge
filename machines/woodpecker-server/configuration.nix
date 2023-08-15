{ self, ... }:
{ pkgs, lib, config, ... }:
{

  imports = [
    # attic.nixosModules.atticd
  ];

  sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  sops.secrets."woodpecker/server-envfile" = { };
  sops.secrets."woodpecker/agent-envfile" = { };
  # sops.secrets."attic/env" = { };

  #services.atticd = {
  #  enable = true;

  #  # Secrets:
  #  # ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64="output from openssl"
  #  # openssl rand 64 | base64 -w0
  #  credentialsFile = config.sops.secrets."attic/envfile".path;

  #  settings = {
  #    listen = "127.0.0.1:7373";

  #    # Data chunking
  #    #
  #    # Warning: If you change any of the values here, it will be
  #    # difficult to reuse existing chunks for newly-uploaded NARs
  #    # since the cutpoints will be different. As a result, the
  #    # deduplication ratio will suffer for a while after the change.
  #    chunking = {
  #      # The minimum NAR size to trigger chunking
  #      #
  #      # If 0, chunking is disabled entirely for newly-uploaded NARs.
  #      # If 1, all NARs are chunked.
  #      nar-size-threshold = 64 * 1024; # 64 KiB

  #      # The preferred minimum size of a chunk, in bytes
  #      min-size = 16 * 1024; # 16 KiB

  #      # The preferred average size of a chunk, in bytes
  #      avg-size = 64 * 1024; # 64 KiB

  #      # The preferred maximum size of a chunk, in bytes
  #      max-size = 256 * 1024; # 256 KiB
  #    };
  #  };
  #};

  # nix.settings.allowed-users = [ config.services.woodpecker-agent.user "woodpecker-agent" ];
  #sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  #sops.secrets = {
  #  # "woodpecker/gitea-client-id".restartUnits = [ "woodpecker-server.service" ];
  #  # "woodpecker/gitea-client-secret".restartUnits = [ "woodpecker-server.service" ];
  #  "woodpecker/server-envfile".restartUnits = [ "woodpecker-server.service" ];
  #  "woodpecker/agent-secret".restartUnits = [ "woodpecker-agent.service" "woodpecker-server.service" ];
  #};
  # rootCredentialsFile = config.sops.secrets."minio/env".path;

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = "woodpecker-server";
  };

  # General stuff
  mayniklas.user.root.enable = true;
  pinpox.services.openssh.enable = true;

  lounge-rocks = {
    hetzner = {
      enable = true;
      interface = "enp1s0";
      ipv6_address = "2a01:4f8:1c17:636f::";
    };
    nix-common.enable = true;
    woodpecker.docker-agent.enable = true;
    woodpecker.local-agent.enable = true;
    woodpecker.pipeliner.enable = true;
    woodpecker.server.enable = true;
  };

  system.stateVersion = "23.05";

}
