{ pkgs, lib, config, ... }:
with lib;
let cfg = config.lounge-rocks.woodpecker.local-agent; in
{

  options.lounge-rocks.woodpecker.local-agent = {
    enable = mkEnableOption "enable local woodpecker agent";
  };

  config = mkIf cfg.enable {

    # Enable git-lfs
    programs.git.enable = true;
    programs.git.lfs.enable = true;

    # local runner
    services.woodpecker-agents.agents = {
      exec = {
        enable = true;
        # package = pkgs.lounge-rocks.woodpecker-agent;

        # Secrets in envfile: WOODPECKER_AGENT_SECRET
        environmentFile = [ config.sops.secrets."woodpecker/agent-envfile".path ];
        environment = {
          WOODPECKER_BACKEND = "local";
          WOODPECKER_SERVER = "100.65.12.86:9000";
          WOODPECKER_MAX_WORKFLOWS = "1";
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

        # CI tools
        attic
        cachix
      ];
    };

    # Allow user to run nix
    nix.settings.allowed-users = [ "woodpecker-agent" ];

    # fixes builds that are failing due to lack of disk space on tmpfs
    # 'note: build failure may have been caused by lack of free disk space'
    boot.tmp.cleanOnBoot = true;
    boot.tmp.tmpfsSize = "4G";
    boot.tmp.useTmpfs = true;

  };

}
