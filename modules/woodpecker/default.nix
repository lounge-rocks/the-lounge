{ lib, config, ... }:

with lib;

let

  # Recursively constructs an attrset of a given folder, recursing on directories, value of attrs is the filetype
  getDir = dir:
    mapAttrs
      (file: type: if type == "directory" then getDir "${dir}/${file}" else type)
      (builtins.readDir dir);

  # Collects all files of a directory as a list of strings of paths
  files = dir:
    collect isString
      (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  # Filters out directories that don't end with .nix or are this file, also makes the strings absolute
  validFiles = dir:
    map (file: ./. + "/${file}") (filter (file: hasSuffix ".nix" file && file != "default.nix") (files dir));

  cfg = config.lounge-rocks.woodpecker;

in
{
  imports = validFiles ./.;

  # options affecting the woodpecker server as well as the woodpecker agents
  options.lounge-rocks.woodpecker = {
    log = mkOption {
      type = types.str;
      default = "info";
      description = "The log level of the woodpecker";
    };
  };

  config = {

    services.woodpecker-server =
      lib.mkIf config.lounge-rocks.woodpecker.server.enable {
        environment = {
          WOODPECKER_LOG_LEVEL = "${cfg.log}";
        };
      };

    services.woodpecker-agents.agents.exec =
      lib.mkIf config.lounge-rocks.woodpecker.local-agent.enable {
        environment = {
          WOODPECKER_LOG_LEVEL = "${cfg.log}";
        };
      };

    services.woodpecker-agents.agents.docker =
      lib.mkIf config.lounge-rocks.woodpecker.docker-agent.enable {
        environment = {
          WOODPECKER_LOG_LEVEL = "${cfg.log}";
        };
      };

  };

}
