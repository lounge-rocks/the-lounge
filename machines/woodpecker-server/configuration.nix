{ self, ... }:
{ pkgs, lib, config, ... }:
{

  sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  sops.secrets."woodpecker/server-envfile" = { };
  sops.secrets."woodpecker/agent-envfile" = { };
  sops.secrets."woodpecker/attic-envfile" = { };

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = "woodpecker-server";
  };

  # General stuff
  mayniklas.user.root.enable = true;
  pinpox.services.openssh.enable = true;

  lounge-rocks = {
    cloud-provider.hetzner = {
      enable = true;
      interface = "enp1s0";
      ipv6_address = "2a01:4f8:1c17:636f::";
    };
    nix-common.enable = true;
    attic.server = {
      enable = true;
      enableNginx = true;
    };
    woodpecker.docker-agent.enable = true;
    woodpecker.local-agent.enable = true;
    woodpecker.pipeliner.enable = true;
    woodpecker.server.enable = true;
  };

  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
