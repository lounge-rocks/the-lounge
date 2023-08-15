{ config, lib, disko, modulesPath, ... }:
with lib;
let cfg = config.lounge-rocks.hetzner;

in {

  options.lounge-rocks.hetzner = {
    enable = mkEnableOption "activate hetzner";
    interface = mkOption {
      type = types.str;
      default = "enp1s0";
      description = "Interface to use";
    };
    ipv6_address = mkOption {
      type = types.str;
      default = "NONE";
      description = "IPv6 address of the server";
    };
  };

  imports = [
    disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = mkIf cfg.enable {

    ### Networking ###
    networking = {
      interfaces.${cfg.interface} = {
        ipv6.addresses = (mkIf (cfg.ipv6_address != "NONE")) [{
          address = "${cfg.ipv6_address}";
          prefixLength = 64;
        }];
      };
      defaultGateway6 = (mkIf (cfg.ipv6_address != "NONE")) {
        address = "fe80::1";
        interface = "${cfg.interface}";
      };
    };

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

    ### Bootloader ###
    boot.loader.grub = {
      devices = [ "/dev/sda" ];
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    ### aarch64-linux specific configuration ###
    boot = {
      kernelParams = lib.optionals (config.nixpkgs.hostPlatform == "aarch64-linux") [
        # workaround because the console defaults to serial
        "console=tty"
      ];
      initrd.kernelModules = lib.optionals (config.nixpkgs.hostPlatform == "aarch64-linux") [
        # initialize the display early to get a complete log
        "virtio_gpu"
      ];
    };

  };
}
