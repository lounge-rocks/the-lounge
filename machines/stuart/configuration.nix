{ self, ... }:
{ pkgs, config, ... }: {

  pinpox.services.openssh.enable = true;

  lounge-rocks = {
    oracle-aarch64.enable = true;
    nix-build-signature.enable = true;
    nix-common.enable = true;
  };

  sops.defaultSopsFile = ../../secrets/stuart/secrets.yaml;
  sops.secrets."minio/env" = {
    restartUnits = [ "minio.service" ];
  };

  networking.hostName = "stuart";

  networking.firewall.allowedTCPPorts = [ 9000 9001 ];

  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    region = "eu-central-1";

    rootCredentialsFile = config.sops.secrets."minio/env".path;

    # dataDir = [ "/mnt/data/minio/data" ];
    # configDir = "/mnt/data/minio/config";
  };

  systemd.services.minio = {

    environment = {
      MINIO_SERVER_URL = "https://s3.lounge.rocks";
      MINIO_BROWSER_REDIRECT_URL = "https://minio.s3.lounge.rocks";
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "mail@lounge.rocks";

  services.nginx = {

    enable = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "128m";
    recommendedProxySettings = true;

    commonHttpConfig = ''
      server_names_hash_bucket_size 128;
      proxy_headers_hash_max_size 1024;
      proxy_headers_hash_bucket_size 256;
    '';

    virtualHosts = {

      # Minio admin console
      "minio.s3.lounge.rocks" = {

        addSSL = true;
        enableACME = true;

        extraConfig = ''
          # To allow special characters in headers
          ignore_invalid_headers off;
          # Allow any size file to be uploaded.
          # Set to a value such as 1000m; to restrict file size to a specific value
          client_max_body_size 0;
          # To disable buffering
          proxy_buffering off;
        '';

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:9001";
            extraConfig = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              # proxy_set_header Host $host;
              proxy_connect_timeout 300;
              # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              chunked_transfer_encoding off;
            '';
          };
        };
      };

      # Minio s3 backend
      "s3.lounge.rocks" = {

        # listen = [{
        #   addr = "192.168.7.1";
        #   port = 443;
        #   ssl = true;
        # }];

        addSSL = true;
        enableACME = true;

        extraConfig = ''
          # To allow special characters in headers
          ignore_invalid_headers off;
          # Allow any size file to be uploaded.
          # Set to a value such as 1000m; to restrict file size to a specific value
          client_max_body_size 0;
          # To disable buffering
          proxy_buffering off;
        '';

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:9000";
            extraConfig = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              # proxy_set_header Host $host;
              proxy_connect_timeout 300;
              # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              chunked_transfer_encoding off;
            '';
          };
        };
      };
    };
  };
}
