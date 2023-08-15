{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.lounge-rocks.woodpecker.local-agent;

  woodpecker-agent-master = pkgs.buildGoModule rec {
    pname = "woodpecker-agent";
    version = "1f956753659204d46d834ac3d0cb68fd71a5b941";

    src = pkgs.fetchFromGitHub {
      owner = "woodpecker-ci";
      repo = "woodpecker";
      rev = "${version}";
      sha256 = "sha256-3RD8FecSMQHUzN8FHUhw+G6zxX4b603IsVvDi+bKNRw=";
    };

    vendorSha256 = "sha256-nSKZTL6YbGma5xB78e5eKrfat3VHK9eVb81yevQkh4g=";

    postInstall = ''
      cd $out/bin
      for f in *; do
        mv -- "$f" "woodpecker-$f"
      done
      cd -
    '';

    ldflags = [
      "-s"
      "-w"
      "-X github.com/woodpecker-ci/woodpecker/version.Version=${version}"
    ];

    subPackages = "cmd/agent";

    CGO_ENABLED = 0;
  };

in
{

  options.lounge-rocks.woodpecker.local-agent = {
    enable = mkEnableOption "enable local woodpecker agent";
  };

  config = mkIf cfg.enable {

    # local runner
    services.woodpecker-agents.agents = {
      exec = {
        enable = true;
        package = woodpecker-agent-master;

        # Secrets in envfile: WOODPECKER_AGENT_SECRET
        environmentFile = [ config.sops.secrets."woodpecker/agent-envfile".path ];
        environment = {
          WOODPECKER_BACKEND = "local";
          WOODPECKER_SERVER = "127.0.0.1:9000";
          WOODPECKER_MAX_WORKFLOWS = "10";
          WOODPECKER_FILTER_LABELS = "type=exec";
          WOODPECKER_HEALTHCHECK = "false";
          NIX_REMOTE = "daemon";
          WOODPECKER_LOG_LEVEL = "info";
          PAGER = "cat";
        };
      };
    };

    # Adjust runner service for nix usage
    systemd.services.woodpecker-agent-exec = {

      serviceConfig = {
        # Same option as upstream, without @setuid
        SystemCallFilter = lib.mkForce
          "~@clock @privileged @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @reboot @swap";

        User = "woodpecker-agent";

        BindPaths = [ "/nix/var/nix/daemon-socket/socket" "/run/nscd/socket" ];
        BindReadOnlyPaths = [
          "/etc/passwd:/etc/passwd"
          "/etc/group:/etc/group"
          "/etc/nix:/etc/nix"
          "${
          config.environment.etc."ssh/ssh_known_hosts".source
        }:/etc/ssh/ssh_known_hosts"
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

  };

}
