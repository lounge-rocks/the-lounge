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

  networking.hostName = "woodpecker-agent-aarch64-1";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
