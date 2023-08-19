{ lib, config, ... }:
with lib;
let cfg = config.lounge-rocks.nginx; in
{

  options.lounge-rocks.nginx = {
    enable = mkEnableOption "enable nginx";
  };

  config = mkIf cfg.enable {

    # ACME config
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@pablo.tools";
    };

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
    };

    networking.firewall.allowedTCPPorts = [ 443 80 ];

  };
}
