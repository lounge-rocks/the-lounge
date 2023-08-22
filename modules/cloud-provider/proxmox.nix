# Proxmox PVE settings
# Processors: CPU type host
# BIOS: OVMF (UEFI)
# Machine: Default (i440fx)
# SCSI Controller: VirtIO SCSI
# Hard Disk: VirtIO Block

# deploying a Proxmox system via nix-anywhere:
# nix run github:numtide/nixos-anywhere -- --flake .#<host> root@<ip>

{ config, lib, modulesPath, ... }:
with lib;
let cfg = config.lounge-rocks.cloud-provider.proxmox;

in {

  options.lounge-rocks.cloud-provider.proxmox = {
    enable = mkEnableOption "activate proxmox";
  };

  config = mkIf cfg.enable {

    ### Partitioning ###
    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/vda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            start = "0";
            end = "1M";
            flags = [ "bios_grub" ];
          }
          {
            name = "ESP";
            start = "1M";
            end = "512M";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "nixos";
            start = "512M";
            end = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          }
        ];
      };
    };

    ### Bootloader ###
    boot.loader.grub = {
      device = "/dev/vda";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    boot.initrd.availableKernelModules = [ "9p" "9pnet_virtio" "ata_piix" "uas" "uhci_hcd" "virtio_blk" "virtio_mmio" "virtio_net" "virtio_pci" "virtio_scsi" ];
    boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
    boot.kernelModules = [ "kvm-intel" ];

    boot.growPartition = true;

  };
}
