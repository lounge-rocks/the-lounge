{ self, ... }:
{ pkgs, lib, config, ... }:
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

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  networking.hostName = "woodpecker-agent-x86-1";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
