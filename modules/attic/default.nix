{ lib, config, attic, ... }:
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
        ensurePermissions = {
          "DATABASE atticd" = "ALL PRIVILEGES";
        };
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
          region = "us-east-005";
          bucket = "lounge-rocks-cache";
          endpoint = "https://s3.us-east-005.backblazeb2.com";
        };

        database.url = "postgresql:///atticd?user=atticd&host=/run/postgresql";

        garbage-collection = {
          interval = "12 hours";
          default-retention-period = "3 months";
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
      };
    };

  };
}
