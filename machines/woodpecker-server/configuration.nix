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
    attic.enable = true;
    # nginx.geoIP = true;
    nix-common.enable = true;
    tailscale.enable = true;
    # woodpecker.pipeliner.enable = true;
    woodpecker.server.enable = true;
    woodpecker.log = "trace";
  };

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = "woodpecker-server";
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
