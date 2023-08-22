{ lib, config, modulesPath, disko, ... }:

with lib;

let

  # Recursively constructs an attrset of a given folder, recursing on directories, value of attrs is the filetype
  getDir = dir:
    mapAttrs
      (file: type: if type == "directory" then getDir "${dir}/${file}" else type)
      (builtins.readDir dir);

  # Collects all files of a directory as a list of strings of paths
  files = dir:
    collect isString
      (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  # Filters out directories that don't end with .nix or are this file, also makes the strings absolute
  validFiles = dir:
    map (file: ./. + "/${file}") (filter (file: hasSuffix ".nix" file && file != "default.nix") (files dir));

  cfg = config.lounge-rocks.cloud-provider;

in
{
  imports = validFiles ./. ++ [
    disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
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