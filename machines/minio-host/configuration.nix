{ self, ... }:
{ pkgs, ... }: {

  pinpox.services.openssh.enable = true;

  lounge-rocks = {
    oracle-aarch64.enable = true;
    nix-build-signature.enable = true;
    nix-common.enable = true;
  };


  sops.defaultSopsFile = ../../secrets/minio_host/secrets.yaml;

  sops.secrets.example_key = {};

  networking = { hostName = "minio-host"; };

  networking.firewall.allowedTCPPorts = [ 9000 9001 ];

  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    region = "eu-central-1";

    rootCredentialsFile = "/var/src/secrets/minio/env";
# MINIO_ROOT_USER=admin
# MINIO_ROOT_PASSWORD=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    # dataDir = [ "/mnt/data/minio/data" ];
    # configDir = "/mnt/data/minio/config";
  };

  systemd.services.minio = {

    environment = {
      MINIO_SERVER_URL = "https://s3.pablo.tools";
      MINIO_BROWSER_REDIRECT_URL = "https://minio.lounge.rocks";
    };
  };

}
