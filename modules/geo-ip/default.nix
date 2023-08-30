{ config, lib, pkgs, github-meta, ... }:
with lib;
let
  cfg = config.lounge-rocks.nginx;
  # Used for allowing GitHub webhooks to trigger our CI
  github_json = (builtins.fromJSON (builtins.readFile github-meta));
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
              ES yes;
              FR yes;
              GB yes;
              IT yes;
              NL yes;
            }
          ''
          # we want to allow GitHub webhooks to trigger our CI
          # if a request is not from GitHub, we return no, which will result in a 403
          ''
            geo $allowed_github {
              default no;
              ${lib.concatStringsSep "\n" (map (ip: "${ip} yes;") github_json.hooks)}
            }
          ''
        ]
      );
      # woodpecker server
      virtualHosts."${config.lounge-rocks.woodpecker.server.hostName}" =
        mkIf config.lounge-rocks.woodpecker.server.enable {
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

