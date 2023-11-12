{ self, ... }:
{ pkgs, lib, config, ... }:
{

  imports = [ ./jitsi.nix ];

  lounge-rocks.jitsi.enable = true;
  lounge-rocks.nginx.enable = true;

  lounge-rocks = {
    users = { MayNiklas.root = true; };
    cloud-provider.hetzner = {
      enable = true;
      interface = "enp1s0";
      ipv6_address = "2a01:4f8:1c1e:864f::";
    };
    nix-common.enable = true;
  };

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = "meet";
    domain = "lounge.rocks";
  };

  lollypops.deployment = {
    local-evaluation = true;
    ssh = { user = "root"; host = "${config.networking.fqdn}"; };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
