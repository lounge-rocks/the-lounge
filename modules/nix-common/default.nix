{ config, pkgs, lib, ... }:

with lib;
let cfg = config.lounge-rocks.nix-common;

in {

  options.lounge-rocks.nix-common = {
    enable = mkEnableOption "activate nix-common";
    disable-cache = mkEnableOption "not use binary-cache";
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
    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };

    # nix
    nix = {
      # Enable flakes
      package = pkgs.nixVersions.stable;
      extraOptions = ''
        experimental-features = nix-command flakes
        # Free up to 5GiB whenever there is less than 1GiB left.
        min-free = ${toString (1 * 1024 * 1024 * 1024)}
        max-free = ${toString (5 * 1024 * 1024 * 1024)}
      '';
      # binary cache -> build by DroneCI
      settings.trusted-public-keys = mkIf (cfg.disable-cache != true)
        [ "cache.lounge.rocks:uXa8UuAEQoKFtU8Om/hq6d7U+HgcrduTVr8Cfl6JuaY=" ];
      settings.substituters = mkIf (cfg.disable-cache != true) [
        "https://cache.nixos.org"
        "https://s3.lounge.rocks/nix-cache?priority=50"
      ];
      settings.trusted-substituters = mkIf (cfg.disable-cache != true) [
        "https://cache.nixos.org"
        "https://s3.lounge.rocks/nix-cache/"
      ];
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
