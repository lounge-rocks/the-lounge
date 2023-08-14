{ self, ... }:
{ pkgs, lib, config, flake-pipeliner, ... }: {

  imports = [
    flake-pipeliner.nixosModules.flake-pipeliner
    # attic.nixosModules.atticd
  ];

  sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  sops.secrets."woodpecker/server-envfile" = { };
  sops.secrets."woodpecker/agent-envfile" = { };
  # sops.secrets."attic/env" = { };

  services.nginx = {

    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "128m";
    recommendedProxySettings = true;

    commonHttpConfig = ''
      server_names_hash_bucket_size 128;
      proxy_headers_hash_max_size 1024;
      proxy_headers_hash_bucket_size 256;
    '';

    virtualHosts."build.lounge.rocks" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
      };
    };
  };


  # Server

  services.woodpecker-server = {
    enable = true;

    # Secrets in env file: WOODPECKER_GITHUB_CLIENT, WOODPECKER_GITHUB_SECRET,
    # WOODPECKER_AGENT_SECRET, WOODPECKER_PROMETHEUS_AUTH_TOKEN
    environmentFile = config.sops.secrets."woodpecker/server-envfile".path;

    environment = {
      WOODPECKER_HOST = "https://build.lounge.rocks";
      WOODPECKER_OPEN = "false";
      WOODPECKER_GITHUB = "true";
      WOODPECKER_ADMIN = "pinpox,MayNiklas"; # Add multiple users as "user1,user2"
      WOODPECKER_ORGS = "lounge-rocks";
      WOODPECKER_CONFIG_SERVICE_ENDPOINT = "http://127.0.0.1:8585";
    };
  };

  # Agents
  services.woodpecker-agents.agents = {
    exec = {
      enable = true;
      # Secrets in envfile: WOODPECKER_AGENT_SECRET
      environmentFile = [ config.sops.secrets."woodpecker/agent-envfile".path ];
      environment = {
        WOODPECKER_BACKEND = "local";
        WOODPECKER_SERVER = "127.0.0.1:9000";
        WOODPECKER_MAX_WORKFLOWS = "10";
        WOODPECKER_FILTER_LABELS = "type=exec";
        WOODPECKER_HEALTHCHECK = "false";
        NIX_REMOTE = "daemon";
        PAGER = "cat";
      };
    };
  };


  # Adjust runner service for nix usage
  systemd.services.woodpecker-agent-exec = {

    serviceConfig = {
      # Same option as upstream, without @setuid
      SystemCallFilter = lib.mkForce "~@clock @privileged @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @swap";

      User = "woodpecker-agent";

      BindPaths = [
        "/nix/var/nix/daemon-socket/socket"
        "/run/nscd/socket"
      ];
      BindReadOnlyPaths = [
        "/etc/passwd:/etc/passwd"
        "/etc/group:/etc/group"
        "/etc/nix:/etc/nix"
        "${config.environment.etc."ssh/ssh_known_hosts".source}:/etc/ssh/ssh_known_hosts"
        "/etc/machine-id"
        # channels are dynamic paths in the nix store, therefore we need to bind mount the whole thing
        "/nix/"
      ];
    };

    path = with pkgs; [
      woodpecker-plugin-git
      bash
      coreutils
      git
      git-lfs
      gnutar
      gzip
      nix
    ];
  };

  # Allow user to run nix
  nix.settings.allowed-users = [ "woodpecker-agent" ];

  # Pipeliner
  services.flake-pipeliner = {
    enable = true;
    environment = {

      PIPELINER_PUBLIC_KEY_FILE = "${./woodpecker-public-key}";
      PIPELINER_HOST = "localhost:8585";
      PIPELINER_OVERRIDE_FILTER = "test-*";
      PIPELINER_SKIP_VERIFY = "false";
      PIPELINER_FLAKE_OUTPUT = "woodpecker-pipeline";
      PIPELINER_DEBUG = "true";
      NIX_REMOTE = "daemon";
      PRE_CMD = "git -v";
      PAGER = "cat";
    };
  };

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



  # GENERAL STUFF
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # nix.settings.allowed-users = [ config.services.woodpecker-agent.user "woodpecker-agent" ];
  #sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  #sops.secrets = {
  #  # "woodpecker/gitea-client-id".restartUnits = [ "woodpecker-server.service" ];
  #  # "woodpecker/gitea-client-secret".restartUnits = [ "woodpecker-server.service" ];
  #  "woodpecker/server-envfile".restartUnits = [ "woodpecker-server.service" ];
  #  "woodpecker/agent-secret".restartUnits = [ "woodpecker-agent.service" "woodpecker-server.service" ];
  #};
  # rootCredentialsFile = config.sops.secrets."minio/env".path;

  networking.firewall.allowedTCPPorts = [ 443 80 22 ];
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@pablo.tools";

  # General stuff
  mayniklas.user.root.enable = true;
  pinpox.services.openssh.enable = true;

  networking.hostName = "woodpecker-server";

  lounge-rocks = {
    hetzner = {
      enable = true;
      interface = "enp1s0";
      ipv6_address = "2a01:4f8:1c17:636f::";
    };

    nix-common.enable = true;
  };

  system.stateVersion = "23.05";

}
