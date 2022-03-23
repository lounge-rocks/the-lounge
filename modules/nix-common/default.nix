{ config, pkgs, lib, ... }:

with lib;
let cfg = config.lounge-rocks.nix-common;

in {

  options.lounge-rocks.nix-common = {
    enable = mkEnableOption "activate nix-common";
  };

  config = mkIf cfg.enable {

    # Install some basic utilities
    environment.systemPackages = with pkgs; [ git htop nixfmt ];

    # Openssh
    programs.ssh.startAgent = false;
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      startWhenNeeded = true;
      kbdInteractiveAuthentication = false;
      permitRootLogin = "yes";
    };

    # Locale settings
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };

    # nix
    nix = {
      # Enable flakes
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
        # Free up to 5GiB whenever there is less than 1GiB left.
        min-free = ${toString (1 * 1024 * 1024 * 1024)}
        max-free = ${toString (5 * 1024 * 1024 * 1024)}
      '';
      # Save space by hardlinking store files
      settings.auto-optimise-store = true;
      # Clean up old generations after 30 days
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

  };
}
