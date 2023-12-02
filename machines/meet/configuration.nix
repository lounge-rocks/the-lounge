# nix run github:numtide/nixos-anywhere -- --flake .#meet root@meet.lounge.rocks
# nix run .\#lollypops -- meet

{ self, ... }:
{ pkgs, lib, config, ... }:
{

  lounge-rocks = {
    cloud-provider.netcup = {
      enable = true;
      ipv6_address = "2a03:4000:40:1c0:94d4:8eff:fea9:2fa6";
    };
    jitsi.enable = true;
    nix-common.enable = true;
    users.MayNiklas.root = true;
  };

  swapDevices = [{ device = "/var/swapfile"; size = (1024 * 2); }];

  lollypops.deployment = {
    local-evaluation = true;
    ssh = { user = "root"; host = "${config.networking.fqdn}"; };
  };

  networking = {
    domain = "lounge.rocks";
    hostName = "meet";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
