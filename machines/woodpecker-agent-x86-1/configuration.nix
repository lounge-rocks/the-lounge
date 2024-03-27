# nix run .\#lollypops -- woodpecker-agent-x86-1
# nix run github:numtide/nixos-anywhere -- --flake .#woodpecker-agent-x86-1 -p 22 root@<IP>
{ self, ... }:
{ pkgs, lib, config, ... }:
{

  lounge-rocks = {
    cloud-provider.enable = true;
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

  boot = {
    kernelModules = [ "kvm-amd" ];
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    initrd = {
      availableKernelModules = [
        "9p"
        "9pnet_virtio"
        "ata_piix"
        "sd_mod"
        "sr_mod"
        "uas"
        "uhci_hcd"
        "virtio_blk"
        "virtio_mmio"
        "virtio_net"
        "virtio_pci"
        "virtio_scsi"
      ];
      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
    };
  };

  swapDevices = [{ device = "/var/swapfile"; size = (1024 * 32); }];
  networking.hostName = "woodpecker-agent-x86-1";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
