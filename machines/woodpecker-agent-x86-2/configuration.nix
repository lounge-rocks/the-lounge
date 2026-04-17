# nix run .\#lollypops -- woodpecker-agent-x86-2
{ self, ... }:
{
  pkgs,
  lib,
  config,
  ...
}:
{

  lounge-rocks = {
    cloud-provider.proxmox.enable = true;
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
    host = "100.101.16.26";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "woodpecker-agent-x86-2";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
