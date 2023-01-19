{ config, lib, pkgs, pinpox, ... }:

with lib;

let
  cfg = config.services.woodpecker-agent;
  servercfg = config.services.woodpecker-server;
in
{
  options = {
    services.woodpecker-agent = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = lib.mdDoc "Enable Woodpecker agent.";
      };

      package = mkOption {
        default = pkgs.woodpecker-agent;
        type = types.package;
        defaultText = literalExpression "pkgs.woodpecker-agent";
        description = lib.mdDoc "woodpecker-agent derivation to use";
      };

      user = mkOption {
        type = types.str;
        default = "woodpecker-agent";
        description = lib.mdDoc "User account under which woodpecker agent runs.";
      };

      agentSecretFile = mkOption {
        type = types.nullOr types.path;
        default = servercfg.agentSecretFile;
        description = lib.mdDoc "Read the agent secret from this file path.";
      };

      maxProcesses = mkOption {
        type = types.int;
        default = 1;
        description = lib.mdDoc "The maximum number of processes per agent.";
      };

      backend = mkOption {
        type = types.enum [ "auto-detect" "docker" "local" "ssh" ];
        default = "auto-detect";
        description = lib.mdDoc "Configures the backend engine to run pipelines on.";
      };

      server = mkOption {
        type = types.str;
        default = "127.0.0.1:${if servercfg.enable then toString servercfg.gRPCPort else "9000"}";
        description = lib.mdDoc "The gPRC address of the server.";
      };
    };
  };

  config = mkIf cfg.enable {


    # TODO remove here
    nix.settings.allowed-users = [ cfg.user ];


    systemd.services.woodpecker-agent = {
      description = "woodpecker-agent";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];


      confinement.enable = true;
      confinement.packages =
        [ pkgs.git pkgs.gnutar pkgs.bash pkgs.nixUnstable pkgs.gzip ];


      restartIfChanged = false;


      path = [
        pinpox.packages.x86_64-linux.woodpecker-plugin-git
        pkgs.bash
        pkgs.bind
        pkgs.dnsutils
        pkgs.git
        pkgs.gnutar
        pkgs.gzip
        pkgs.nixUnstable
        pkgs.openssh
      ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = "woodpecker-agent";
        ExecStart = "${cfg.package}/bin/woodpecker-agent";
        Restart = "always";
        # TODO add security/sandbox params.


        Environment = [
          "NIX_REMOTE=daemon"
          "PAGER=cat"
        ];

        BindPaths = [
          "/nix/var/nix/daemon-socket/socket"
          "/run/nscd/socket"
          # TODO This was enabled in drone
          "/var/lib/woodpecker-agent"
        ];
        BindReadOnlyPaths = [
          "/etc/passwd:/etc/passwd"
          "/etc/resolv.conf:/etc/resolv.conf"
          "/etc/hosts:/etc/hosts"
          "/etc/group:/etc/group"
          "/nix/var/nix/profiles/system/etc/nix:/etc/nix"
          "${
            config.environment.etc."ssl/certs/ca-certificates.crt".source
          }:/etc/ssl/certs/ca-certificates.crt"
          "${
            config.environment.etc."ssh/ssh_known_hosts".source
          }:/etc/ssh/ssh_known_hosts"
          # "${
          #   builtins.toFile "ssh_config" ''
          #     Host eve.thalheim.io
          #       ForwardAgent yes
          #   ''
          # }:/etc/ssh/ssh_config"
          "/etc/machine-id"
          # channels are dynamic paths in the nix store, therefore we need to bind mount the whole thing
          "/nix/"
        ];


        # EnvironmentFile = [ config.lollypops.secrets.files."woodpecker/agent-envfile".path ];
      };
      environment = mkMerge [
        {
          WOODPECKER_MAX_WORKFLOWS = "3";
          WOODPECKER_SERVER = cfg.server;
          WOODPECKER_MAX_PROCS = toString cfg.maxProcesses;
          WOODPECKER_BACKEND = cfg.backend;

          # TODO remove
          WOODPECKER_LOG_LEVEL = "debug";
          WOODPECKER_DEBUG_PRETTY = "true";
          WOODPECKER_HEALTHCHECK_ADDR = "localhost:3003";

        }
        (mkIf (cfg.agentSecretFile != null) {
          WOODPECKER_AGENT_SECRET_FILE = cfg.agentSecretFile;
        })
      ];
    };

    users.users = mkIf (cfg.user == "woodpecker-agent") {
      woodpecker-agent = {
        createHome = true;
        home = "/var/lib/woodpecker-agent";
        useDefaultShell = true;
        group = "woodpecker-agent";
        extraGroups = [ "woodpecker" ];
        isSystemUser = true;
      };
    };
    users.groups.woodpecker-agent = { };
  };
}
