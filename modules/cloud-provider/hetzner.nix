{ config, lib, ... }:
with lib;
let cfg = config.lounge-rocks.cloud-provider.hetzner;

in {

  options.lounge-rocks.cloud-provider.hetzner = {
    enable = mkEnableOption "hetzner configuration";
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

  config = mkIf cfg.enable {

    # enable our base module that is common across all providers
    lounge-rocks.cloud-provider.enable = true;

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

    ### aarch64-linux specific configuration ###
    boot = {
      kernelParams = lib.optionals (config.nixpkgs.hostPlatform.system == "aarch64-linux") [
        # workaround because the console defaults to serial
        "console=tty"
      ];
      initrd.kernelModules = lib.optionals (config.nixpkgs.hostPlatform.system == "aarch64-linux") [
        # initialize the display early to get a complete log
        "virtio_gpu"
      ];
    };

  };
}
