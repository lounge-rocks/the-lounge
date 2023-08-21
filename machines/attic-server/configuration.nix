{ self, ... }:
{ pkgs, lib, config, ... }:
{

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = "attic-server";
  };

  mayniklas.user.root.enable = true;

  lounge-rocks = {
    # attic.server.enable = true;
    nix-common.enable = true;
    proxmox.enable = true;
  };

  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
