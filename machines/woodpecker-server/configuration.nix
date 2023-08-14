{ self, ... }:
{ pkgs, pinpox-woodpecker, modulesPath, config, ... }: {

  imports = [
    # disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub = {
    devices = [ "/dev/sda" ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

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
  lounge-rocks.nix-common.enable = true;
  mayniklas.user.root.enable = true;
  pinpox.services.openssh.enable = true;

  networking = {
    hostName = "woodpecker-server";

    # set cfg.ipv6_address to the IPv6 address of the server
    # set cfg.interface to the interface to use
    interfaces.enp1s0 = {
      ipv6.addresses =
        [
          {
            address = "2a01:4f8:1c17:636f::";
            prefixLength = 64;
          }
        ];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
  };

  # system.stateVersion = "22.05";

  # aarch64-linux specific
  # workaround because the console defaults to serial
  boot.kernelParams = [ "console=tty" ];
  # initialize the display early to get a complete log
  boot.initrd.kernelModules = [ "virtio_gpu" ];

}
