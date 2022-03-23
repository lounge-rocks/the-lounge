{ config, pkgs, lib, modulesPath, ... }:

with lib;
let cfg = config.lounge-rocks.netcup-x86;

in {

  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  options.lounge-rocks.netcup-x86 = {
    enable = mkEnableOption "activate netcup-x86";
  };

  config = mkIf cfg.enable {

    # Filesystems
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    # Bootloader
    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "/dev/sda";
    boot.loader.timeout = 15;

    # swapfile
    swapDevices = [{
      device = "/var/swapfile";
      size = (1024 * 8);
    }];

  };
}
