{ self, ... }:
{ pkgs, lib, config, ... }:
{

  sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  sops.secrets."woodpecker/server-envfile" = { };
  sops.secrets."woodpecker/agent-envfile" = { };
  sops.secrets."woodpecker/attic-envfile" = { };


  services.nginx.virtualHosts."cache.lounge.rocks" = lib.mkIf config.lounge-rocks.attic.enable {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:7373";
      extraConfig = ''
        client_max_body_size 1024m;
      '';
    };
  };

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = "woodpecker-server";
  };

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
    tailscale.enable = true;
    nix-common.enable = true;
    attic.enable = true;
    # woodpecker.docker-agent.enable = true;
    # woodpecker.local-agent.enable = true;
    woodpecker.pipeliner.enable = true;
    woodpecker.server.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
