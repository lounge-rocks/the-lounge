{ config, pkgs, lib, ... }:

with lib;
let cfg = config.lounge-rocks.cloud-provider.oracle;

in {

  options.lounge-rocks.cloud-provider.oracle = {
    enable = mkEnableOption "activate oracle-aarch64";
  };

  config = mkIf cfg.enable {

    # enable our base module that is common across all providers
    lounge-rocks.cloud-provider.enable = true;

    ### aarch64-linux specific configuration ###
    boot = {
      kernelParams = lib.optionals (config.nixpkgs.hostPlatform.system == "aarch64-linux") [ ];
      initrd.kernelModules = lib.optionals (config.nixpkgs.hostPlatform.system == "aarch64-linux") [ ];
    };

  };
}
