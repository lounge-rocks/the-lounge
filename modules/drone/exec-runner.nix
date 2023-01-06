{ lib, pkgs, config, ... }:
with lib;
let cfg = config.lounge-rocks.drone.exec-runner;
in {

  options.lounge-rocks.drone.exec-runner = {
    enable = mkEnableOption "enable drone-exec-runner";
    package = mkOption {
      type = types.package;
      default = pkgs.drone-runner-exec;
      defaultText = literalExpression "pkgs.drone-runner-exec";
      description = lib.mdDoc ''
        The drone-runner-exec package to use.
      '';
    };
  };

  config = mkIf cfg.enable {

    # won't work - the newest won't build with Nix (go.mod is broken).
    # we COULD use the pre-build binary...

    # lounge-rocks.drone.exec-runner.package = pkgs.buildGoModule rec {
    #   pname = "drone-runner-exec";
    #   version = "unstable-2022-06-22";

    #   src = pkgs.fetchFromGitHub {
    #     owner = "drone-runners";
    #     repo = "drone-runner-exec";
    #     rev = "9decf2941d423d0ee4faff892b5e8d8ab657fe36";
    #     sha256 = "sha256-dQIN0DXH9j4Qu0Q8vwHjTG/lrtThHnR2bc1UymuUACI=";
    #   };

    #   vendorSha256 = "sha256-ypYuQKxRhRQGX1HtaWt6F6BD9vBpD8AJwx/4esLrJsw=";

    #   meta = with lib; {
    #     description = "Drone pipeline runner that executes builds directly on the host machine";
    #     homepage = "https://github.com/drone-runners/drone-runner-exec";
    #     license = licenses.unfree;
    #     maintainers = with maintainers; [ mic92 ];
    #   };
    # };

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
        ExecStart = "${cfg.package}/bin/drone-runner-exec";
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
