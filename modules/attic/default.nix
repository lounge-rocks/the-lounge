{ lib, config, attic, pkgs, ... }:
with lib;
let cfg = config.lounge-rocks.attic; in
{

  imports = [ attic.nixosModules.atticd ];

  options.lounge-rocks.attic = {
    enable = mkEnableOption "attic server";
    host = mkOption {
      type = types.str;
      default = "cache.lounge.rocks";
      description = "The hostname of the attic server";
    };

    retention-period = mkOption {
      type = types.int;
      default = 60 * 60 * 24 * 31;
      description = ''
        The default retention period for garbage collection.
      '';
    };

    scaling-factor = mkOption {
      type = types.int;
      default = 1;
      description = ''
        The scaling factor for the chunking parameters.
        The settings are multiplied by this factor.
      '';
    };
  };

  config = mkIf cfg.enable {

    # https://docs.attic.rs/admin-guide/deployment/nixos.html
    # https://github.com/zhaofengli/attic/blob/main/nixos/atticd.nix

    services.nginx.virtualHosts."${cfg.host}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:7373";
        extraConfig = ''
          client_max_body_size 8192m;
        '';
      };
    };

    services.postgresql = {
      enable = true;
      ensureUsers = [{
        name = "atticd";
        # TODO: needs to be migrated into the new optionscd
        # ensurePermissions = { "DATABASE atticd" = "ALL PRIVILEGES"; };
      }];
      ensureDatabases = [ "atticd" ];
    };

    services.atticd = {
      enable = true;

      # TODO: document all the secrets we put in our envfile

      # Secrets:
      # ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64="output from openssl"
      # openssl rand 64 | base64 -w0

      # Replace with absolute path to your credentials file
      credentialsFile = config.sops.secrets."woodpecker/attic-envfile".path;

      settings = {

        # available options:
        # https://github.com/zhaofengli/attic/blob/main/server/src/config-template.toml
        listen = "127.0.0.1:7373";
        api-endpoint = "https://${cfg.host}/";

        storage = {
          type = "s3";
          region = "eu-central-003";
          bucket = "lounge-rocks-attic";
          endpoint = "https://s3.eu-central-003.backblazeb2.com";
        };

        database.url = "postgresql:///atticd?user=atticd&host=/run/postgresql";

        garbage-collection = {
          interval = "12 hours";
          default-retention-period = "${toString (cfg.retention-period)}s";
        };

        # Data chunking
        # Warning: If you change any of the values here, it will be
        # difficult to reuse existing chunks for newly-uploaded NARs
        # since the cutpoints will be different. As a result, the
        # deduplication ratio will suffer for a while after the change.
        chunking = {
          # The minimum NAR size to trigger chunking
          #
          # If 0, chunking is disabled entirely for newly-uploaded NARs.
          # If 1, all NARs are chunked.
          nar-size-threshold = cfg.scaling-factor * 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = cfg.scaling-factor * 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = cfg.scaling-factor * 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = cfg.scaling-factor * 256 * 1024; # 256 KiB
        };

        compression = {
          type = "zstd";
        };

      };
    };

    environment.systemPackages =
      let
        atticadmShim = pkgs.writeShellScript "atticadm" ''
          # if [ -n "$ATTICADM_PWD" ]; then
          #   cd "$ATTICADM_PWD"
          #   if [ "$?" != "0" ]; then
          #     >&2 echo "Warning: Failed to change directory to $ATTICADM_PWD"
          #   fi
          # fi
          cd /var/lib/atticd
          export RUST_LOG=debug
          exec ${config.services.atticd.package}/bin/atticd -f ${config.services.atticd.configFile} "$@"
        '';
      in
      [
        (pkgs.writeShellScriptBin "attic-gc" ''
          exec systemd-run \
            --quiet \
            --pty \
            --same-dir \
            --wait \
            --collect \
            --service-type=exec \
            --property=EnvironmentFile=${config.services.atticd.credentialsFile} \
            --property=DynamicUser=yes \
            --property=User=${config.services.atticd.user} \
            --property=Environment=ATTICADM_PWD=$(pwd) \
            --working-directory / \
            -- \
            ${atticadmShim} "$@"
        '')
      ];

  };
}
