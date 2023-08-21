# Proxmox PVE settings
# Processors: CPU type host
# BIOS: OVMF (UEFI)
# Machine: Default (i440fx)
# SCSI Controller: VirtIO SCSI
# Hard Disk: VirtIO Block

{ config, lib, disko, modulesPath, ... }:
with lib;
let cfg = config.lounge-rocks.proxmox;

in {

  options.lounge-rocks.proxmox = {
    enable = mkEnableOption "activate proxmox";
  };

  imports = [
    # allready imported by hetzner module
    # -> can't be imported twice
    # maybe we should move those imports to the flake.nix?
    # or: only import modules where we need them?
    # disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = mkIf cfg.enable {

    ### Partitioning ###
    disko = {
      devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/sda";
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
        };
      };
    };

    # reduce size of the VM
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    ### Bootloader ###
    boot.loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };


    boot.initrd.availableKernelModules = [ "9p" "9pnet_virtio" "ata_piix" "uas" "uhci_hcd" "virtio_blk" "virtio_mmio" "virtio_net" "virtio_pci" "virtio_scsi" ];
    boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
    boot.kernelModules = [ "kvm-intel" ];

    boot.growPartition = true;

    services.qemuGuest.enable = true;

  };
}
