{ lib, config, attic, ... }:
with lib;
let cfg = config.lounge-rocks.attic.server; in
{

  imports = [ attic.nixosModules.atticd ];

  options.lounge-rocks.attic.server = {
    enable = mkEnableOption "enable attic server";
  };

  config = mkIf cfg.enable {

    services.nginx = {
      virtualHosts."attic.lounge.rocks" = {
        addSSL = true;
        enableACME = true;
        locations."/" = { proxyPass = "http://127.0.0.1:7373"; };
      };
    };

    # https://docs.attic.rs/admin-guide/deployment/nixos.html
    # https://github.com/zhaofengli/attic/blob/main/nixos/atticd.nix

    services.atticd = {
      enable = true;

      # Secrets:
      # ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64="output from openssl"
      # openssl rand 64 | base64 -w0

      # Replace with absolute path to your credentials file
      credentialsFile = config.sops.secrets."woodpecker/attic-envfile".path;

      settings = {
        listen = "127.0.0.1:7373";

        # Data chunking
        #
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
