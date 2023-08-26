{ lib, config, attic, ... }:
with lib;
let cfg = config.lounge-rocks.attic.server; in
{

  imports = [ attic.nixosModules.atticd ];

  options.lounge-rocks.attic.server = {
    enable = mkEnableOption "enable attic server";
  };

  config = mkIf cfg.enable {

    # https://docs.attic.rs/admin-guide/deployment/nixos.html
    # https://github.com/zhaofengli/attic/blob/main/nixos/atticd.nix

    services.postgresql = {
      enable = true;
      ensureUsers = [{
        name = "attic";
        ensurePermissions = {
          "DATABASE attic" = "ALL PRIVILEGES";
        };
      }];
      ensureDatabases = [ "attic" ];
    };

    services.atticd = {
      enable = true;

      # Secrets:
      # ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64="output from openssl"
      # openssl rand 64 | base64 -w0

      # Replace with absolute path to your credentials file
      credentialsFile = config.sops.secrets."woodpecker/attic-envfile".path;

      settings = {

        # available options:
        # https://github.com/zhaofengli/attic/blob/main/server/src/config-template.toml
        listen = "127.0.0.1:7373";
        api-endpoint = "https://cache.lounge.rocks/";

        storage = {
          type = "s3";
          region = "us-east";
          bucket = "attic";
          endpoint = "https://s3.us-east-005.backblazeb2.com";
        };

        database.url = "pqsql:dbname=attic;host=/run/postgresql;port=5442";

        compression.type = "zstd";

        garbage-collection = {
          interval = "12 hours";
          default-retention-period = "12 months";
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
          nar-size-threshold = 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };

  };
}
