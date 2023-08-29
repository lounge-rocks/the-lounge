{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.lounge-rocks.nginx;
  # https://api.github.com/meta
  github-IPs = [
    "192.30.252.0/22"
    "185.199.108.0/22"
    "140.82.112.0/20"
    "143.55.64.0/20"
    "2a0a:a440::/29"
    "2606:50c0::/32"
  ];
in
{

  options.lounge-rocks.nginx = {
    geoIP = mkEnableOption "enable GeoIP";
  };

  config = mkIf cfg.geoIP {

    # when Nginx is enabled, enable the GeoIP updater service
    services.geoipupdate = mkIf cfg.enable {
      enable = true;
      interval = "weekly";
      settings = {
        EditionIDs = [ "GeoLite2-Country" ];
        AccountID = 545115;
        LicenseKey = "/var/maxmind_license_key";
        DatabaseDirectory = "/var/lib/GeoIP";
      };
    };

    # build nginx with geoip2 module
    services.nginx = {
      package = pkgs.nginxStable.override (oldAttrs: {
        modules = with pkgs.nginxModules; [ geoip2 ];
        buildInputs = oldAttrs.buildInputs ++ [ pkgs.libmaxminddb ];
      });
      appendHttpConfig = toString (
        [
          # we want to load the geoip2 module in our http config, pointing to the database we are using
          # country iso code is the only data we need
          ''
            geoip2 ${config.services.geoipupdate.settings.DatabaseDirectory}/GeoLite2-Country.mmdb {
              $geoip2_data_country_iso_code country iso_code;
            }
          ''
          # we want to allow only requests from Germany
          # if a request is not from Germany, we return no, which will result in a 403
          ''
            map $geoip2_data_country_iso_code $allowed_country {
              default no;
              DE yes;
            }
          ''
          # we want to allow requests comming from GitHub IPs
          # if a request is not from GitHub, we return no, which will result in a 403
          ''
            map $remote_addr $allowed_github {
              default no;
              ${lib.concatStringsSep "\n" (map (ip: "${ip} yes;") github-IPs)}
            }
          ''
        ]
      );
      # woodpecker server
      virtualHosts."${config.lounge-rocks.woodpecker.server.hostName}" = mkIf config.lounge-rocks.woodpecker.server {
        extraConfig = toString (
          optional config.lounge-rocks.nginx.geoIP ''
            set $allowed 0;

            if ($allowed_country = yes) {
                set $allowed 1;
            }

            if ($allowed_github = yes) {
                set $allowed 1;
            }

            if ($allowed = 0) {
                return 403;
            }
          ''
        );
      };
    };

  };
}
