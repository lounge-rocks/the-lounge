{ config, pkgs, lib, ... }:

with lib;
let cfg = config.lounge-rocks.oracle-aarch64;

in {

  options.lounge-rocks.oracle-aarch64 = {
    enable = mkEnableOption "activate oracle-aarch64";
  };

  config = mkIf cfg.enable {

    boot = {
      loader.grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
      };
      cleanTmpDir = true;
      initrd.kernelModules = [ "nvme" ];
    };
    zramSwap.enable = true;

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-label/UEFI";
        fsType = "vfat";
      };
      "/" = {
        device = "/dev/disk/by-label/cloudimg-rootfs";
        fsType = "ext4";
      };
    };
  };
}
