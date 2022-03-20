{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lounge-rocks.drone.exec-runner;
in {

  options.lounge-rocks.drone.exec-runner = { enable = mkEnableOption "enable drone-exec-runner"; };

  config = mkIf cfg.enable {

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [ "drone-runner-exec" ];

    systemd.services.drone-runner-exec = {
      wantedBy = [ "multi-user.target" ];
      # might break deployment
      restartIfChanged = true;
      confinement.enable = true;
      confinement.packages =
        [ pkgs.git pkgs.gnutar pkgs.bash pkgs.nixUnstable pkgs.gzip ];
      path = [
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
        Environment = [
          "DRONE_RUNNER_CAPACITY=1"
          "DRONE_RPC_PROTO=https"
          "DRONE_RPC_HOST=drone.lounge.rocks"
          "NIX_REMOTE=daemon"
          "PAGER=cat"
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
          "/etc/machine-id"
          # channels are dynamic paths in the nix store, therefore we need to bind mount the whole thing
          "/nix/"
        ];
        EnvironmentFile = [ "/var/src/secrets/drone-ci/envfile" ];
        ExecStart = "${pkgs.drone-runner-exec}/bin/drone-runner-exec";
        User = "drone-runner-exec";
        Group = "drone-runner-exec";
      };
    };

    users.users.drone-runner-exec = {
      isSystemUser = true;
      group = "drone-runner-exec";
    };
    users.groups.drone-runner-exec = { };

    nix.settings.allowed-users = [ "drone-runner-exec" ];

  };
}
