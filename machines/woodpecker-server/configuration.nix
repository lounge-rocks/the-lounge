{ self, ... }:
{ pkgs, lib, config, ... }: {

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";


  # nix.settings.allowed-users = [ config.services.woodpecker-agent.user "woodpecker-agent" ];
  #sops.defaultSopsFile = ../../secrets/woodpecker-server/secrets.yaml;
  #sops.secrets = {
  #  # "woodpecker/gitea-client-id".restartUnits = [ "woodpecker-server.service" ];
  #  # "woodpecker/gitea-client-secret".restartUnits = [ "woodpecker-server.service" ];
  #  "woodpecker/server-envfile".restartUnits = [ "woodpecker-server.service" ];
  #  "woodpecker/agent-secret".restartUnits = [ "woodpecker-agent.service" "woodpecker-server.service" ];
  #};
  # rootCredentialsFile = config.sops.secrets."minio/env".path;

  networking.firewall.allowedTCPPorts = [ 443 80 22 ];

  #   agentSecretFile = "${config.sops.secrets."woodpecker/agent-secret".path}";
  #   environmentFile = "${config.sops.secrets."woodpecker/server-envfile".path}";
  #   agentSecretFile = "${config.sops.secrets."woodpecker/agent-secret".path}";

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "acme@pablo.tools";

  # General stuff
  mayniklas.user.root.enable = true;
  pinpox.services.openssh.enable = true;

  networking = {
    hostName = "woodpecker-server";
  };

  lounge-rocks = {
    hetzner = {
      enable = true;
      interface = "enp1s0";
      ipv6_address = "2a01:4f8:1c17:636f::";
    };

    nix-common.enable = true;
  };

  system.stateVersion = "23.05";

}
