{ self, ... }:
{ pkgs, lib, config, ... }:
{

  imports = [ ./hardware-configuration.nix ];

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = "attic-server";
  };

  mayniklas.user.root.enable = true;

  lounge-rocks = {
    nix-common.enable = true;
    attic.server.enable = true;
  };

  system.stateVersion = "23.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
