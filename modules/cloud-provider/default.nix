{ lib, config, modulesPath, disko, ... }:
with lib;
let
  cfg = config.lounge-rocks.cloud-provider;
in
{
  imports = [
    disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    # provider specific modules
    ./hetzner.nix
    ./netcup.nix
    ./oracle.nix
    ./proxmox.nix
  ];

  options.lounge-rocks.cloud-provider = {
    enable = mkEnableOption "cloud-provider";
    primaryDisk = mkOption {
      type = types.str;
      default = "/dev/sda";
      description = "The name of the primary disk";
    };
  };

  config = mkIf cfg.enable {

    # Running fstrim weekly is a good idea for VMs.
    # Empty blocks are returned to the host, which can then be used for other VMs.
    # It also reduces the size of the qcow2 image, which is good for backups.
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    # We want to standardize our partitions and bootloaders across all providers.
    # See: https://github.com/lounge-rocks/the-lounge/issues/16
    # Currently Hetzner and Proxmox are standardized.
    disko.devices.disk.main = mkIf (cfg.hetzner.enable || cfg.proxmox.enable) {
      type = "disk";
      device = cfg.primaryDisk;
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

    # During boot, resize the root partition to the size of the disk.
    # This makes upgrading the size of the vDisk easier.
    # TODO: can we do this through Disko?
    # Haven't found something about this in the docs yet.
    fileSystems."/".autoResize = true;
    boot.growPartition = true;

    # We want to standardize our partitions and bootloaders across all providers.
    # See: https://github.com/lounge-rocks/the-lounge/issues/16
    # Currently Hetzner and Proxmox are standardized.
    boot.loader.grub = mkIf (cfg.hetzner.enable || cfg.proxmox.enable) {
      devices = [ cfg.primaryDisk ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    # Currently all our providers use KVM / QEMU
    services.qemuGuest.enable = true;

  };

}
