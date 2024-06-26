# Proxmox PVE settings
# Processors: CPU type host
# BIOS: OVMF (UEFI)
# Machine: Default (i440fx)
# SCSI Controller: VirtIO SCSI
# Hard Disk: VirtIO Block

# deploying a Proxmox system via nix-anywhere:
# nix run github:numtide/nixos-anywhere -- --flake .#<host> root@<ip>

{ config, lib, ... }:
with lib;
let cfg = config.lounge-rocks.cloud-provider.proxmox;

in {

  options.lounge-rocks.cloud-provider.proxmox = {
    enable = mkEnableOption "proxmox configuration";
  };

  config = mkIf cfg.enable {

    lounge-rocks.cloud-provider = {
      # enable our base module that is common across all providers
      enable = true;
      # If /dev/sda is not shown, you need to set your disk to VirtIO Block in the Proxmox GUI
      primaryDisk = "/dev/vda";
    };

    boot.initrd.availableKernelModules = [
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
    boot.initrd.kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];
    boot.kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];

  };
}
