{ config, pkgs, lib, ... }:

with lib;
let cfg = config.lounge-rocks.cloud-provider.netcup;

in {

  options.lounge-rocks.cloud-provider.netcup = {
    enable = mkEnableOption "netcup configuration";
    interface = mkOption {
      type = types.str;
      default = "ens3";
      description = "Interface to use";
    };
    ipv6_address = mkOption {
      type = types.str;
      default = "NONE";
      description = "IPv6 address of the server";
    };
  };

  config = mkIf cfg.enable {

    # set cfg.ipv6_address to the IPv6 address of the server
    # set cfg.interface to the interface to use
    networking = {
      interfaces.${cfg.interface} = {
        ipv6.addresses = (mkIf (cfg.ipv6_address != "NONE")) [
          {
            address = "${cfg.ipv6_address}";
            prefixLength = 64;
          }
        ];
      };
    };

    lounge-rocks.cloud-provider = {
      # enable our base module that is common across all providers
      enable = true;
      # make sure VIRTIO disk driver is set
      primaryDisk = "/dev/vda";
    };

    # Bootloader
    boot.kernelParams = [ "console=ttyS0" ];

  };
}
