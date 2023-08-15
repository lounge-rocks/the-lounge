{ config, pkgs, lib, nixpkgs, ... }:

with lib;
let cfg = config.lounge-rocks.nix-common;

in {

  options.lounge-rocks.nix-common = {
    enable = mkEnableOption "activate nix-common";
    disable-cache = mkEnableOption "not use binary-cache";
  };

  config = mkIf cfg.enable {

    # Install some basic utilities
    environment.systemPackages = with pkgs; [ git htop nixfmt nixpkgs-fmt ];

    nixpkgs.overlays = [
      # our packages are accessible via lounge-rocks.<name>
      (final: prev: { lounge-rocks = import ../../pkgs { inherit pkgs; }; })
    ];

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
      package = pkgs.nixVersions.stable;
      extraOptions = ''
        # Enable flakes
        experimental-features = nix-command flakes

         # If set to true, Nix will fall back to building from source if a binary substitute fails.
        fallback = true

        # the timeout (in seconds) for establishing connections in the binary cache substituter. 
        connect-timeout = 10

        # these log lines are only shown on a failed build
        log-lines = 25

        # Free up to 5GiB whenever there is less than 2GiB left.
        min-free = ${toString (2 * 1024 * 1024 * 1024)}
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
      # Set the $NIX_PATH entry for nixpkgs. This is necessary in
      # this setup with flakes, otherwise commands like `nix-shell
      # -p pkgs.htop` will keep using an old version of nixpkgs.
      # With this entry in $NIX_PATH it is possible (and
      # recommended) to remove the `nixos` channel for both users
      # and root e.g. `nix-channel --remove nixos`. `nix-channel
      # --list` should be empty for all users afterwards
      nixPath = [ "nixpkgs=${nixpkgs}" ];
    };

  };
}
