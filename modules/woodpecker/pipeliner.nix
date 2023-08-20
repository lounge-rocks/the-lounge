{ pkgs, lib, config, flake-pipeliner, ... }:
with lib;
let cfg = config.lounge-rocks.woodpecker.pipeliner;
in {

  imports = [
    flake-pipeliner.nixosModules.flake-pipeliner
  ];

  options.lounge-rocks.woodpecker.pipeliner = {
    enable = mkEnableOption "enable woodpecker flakes pipeliner";
  };

  config = mkIf cfg.enable {

    services.flake-pipeliner = {
      enable = true;
      environment = {

        PIPELINER_PUBLIC_KEY_FILE = "${./woodpecker-public-key}";
        PIPELINER_HOST = "localhost:8585";
        PIPELINER_OVERRIDE_FILTER = ".*";
        PIPELINER_SKIP_VERIFY = "false";
        PIPELINER_FLAKE_OUTPUT = "woodpecker-pipeline";
        PIPELINER_DEBUG = "true";
        NIX_REMOTE = "daemon";
        PRE_CMD = "git -v";
        PAGER = "cat";
      };
    };

  };

}
