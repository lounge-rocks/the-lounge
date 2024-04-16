# nix run .\#lollypops -- woodpecker-agent-x86-1
# nix run github:numtide/nixos-anywhere -- --flake .#woodpecker-agent-x86-1 -p 22 root@<IP>
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

  lollypops.deployment.ssh = {
    user = "root";
    host = "192.168.40.2";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  swapDevices = [{ device = "/var/swapfile"; size = (1024 * 32); }];
  networking.hostName = "woodpecker-agent-x86-1";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
