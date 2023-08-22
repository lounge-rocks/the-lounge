{ config, pkgs, lib, ... }:

with lib;
let cfg = config.lounge-rocks.cloud-provider.oracle;

in {

  options.lounge-rocks.cloud-provider.oracle = {
    enable = mkEnableOption "activate oracle-aarch64";
  };

  config = mkIf cfg.enable {

    boot = {
      loader.grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
      };
      tmp.cleanOnBoot = true;
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
