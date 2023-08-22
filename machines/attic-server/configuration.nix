{ self, ... }:
{ pkgs, lib, config, ... }:
{

  networking.hostName = "attic-server";

  mayniklas.user.root.enable = true;

  lounge-rocks = {
    # attic.server.enable = true;
    nix-common.enable = true;
    cloud-provider.proxmox.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
