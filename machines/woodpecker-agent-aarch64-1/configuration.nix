{ self, ... }:
{ pkgs, lib, config, ... }:
{

  lounge-rocks = {
    cloud-provider.oracle.enable = true;
    nix-common.enable = true;
    tailscale.enable = true;
    users.MayNiklas.root = true;
    woodpecker = {
      docker-agent.enable = true;
      local-agent.enable = true;
    };
  };

  lollypops.deployment.ssh = {
    user = "root";
    host = "oracle-aarch64-runner-1.lounge.rocks";
    # host = "${config.networking.fqdn}";
  };

  networking = {
    domain = "lounge.rocks";
    hostName = "woodpecker-agent-aarch64-1";
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
