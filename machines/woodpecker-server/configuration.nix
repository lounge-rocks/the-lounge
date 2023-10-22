{ self, ... }:
{ pkgs, lib, config, ... }:
{

  sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  sops.secrets."woodpecker/server-envfile" = { };
  sops.secrets."woodpecker/agent-envfile" = { };
  sops.secrets."woodpecker/attic-envfile" = { };

  lounge-rocks = {
    users = {
      MayNiklas.root = true;
      pinpox.root = true;
    };
    cloud-provider.hetzner = {
      enable = true;
      interface = "enp1s0";
      ipv6_address = "2a01:4f8:1c17:636f::";
    };
    attic = {
      enable = true;
      scaling-factor = 64;
      retention-period = 60 * 60 * 24 * 31; # 31 days retention - emptied cache on 21st October 2023
    };
    nginx.geoIP = true;
    nix-common.enable = true;
    tailscale.enable = true;
    # woodpecker.pipeliner.enable = true; # TODO fix
    woodpecker.server.enable = true;
    woodpecker.log = "trace";
  };

  lollypops.deployment = {
    local-evaluation = true;
    ssh = {
      user = "root";
      host = "hetzner-build-aarch64.lounge.rocks";
      # host = "${config.networking.fqdn}";
    };
  };

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    domain = "lounge.rocks";
    hostName = "woodpecker-server";
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
