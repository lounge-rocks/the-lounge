{ self, ... }:
{ pkgs, lib, config, ... }:
{

  lounge-rocks = {
    cloud-provider.proxmox.enable = true;
    nix-common.enable = true;
    users.MayNiklas.root = true;
  };

  networking.hostName = "woodpecker-agent-x86-1";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
