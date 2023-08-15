{ config, pkgs, lib, ... }:
with lib;
let cfg = config.lounge-rocks.tailscale;
in {

  options.lounge-rocks.tailscale = {
    enable = mkEnableOption "tailscale";
    exitNode = mkEnableOption "tailscale exit node";
  };

  config = mkIf cfg.enable {

    services.tailscale = {
      enable = true;
      interfaceName = "tailscale0";
      package = pkgs.tailscale;
      port = 39140;
    };

    # strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups
    networking.firewall.checkReversePath = mkIf cfg.exitNode "loose";

  };

}
