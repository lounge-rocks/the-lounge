{ config, pkgs, lib, ... }:

with lib;
let cfg = config.lounge-rocks.cloud-provider.netcup;

in {

  options.lounge-rocks.cloud-provider.netcup = {
    enable = mkEnableOption "activate netcup";
  };

  config = mkIf cfg.enable {

    # Filesystems
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    # Bootloader
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
