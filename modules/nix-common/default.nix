{ config, pkgs, lib, self, nixpkgs, attic, cachix, ... }:

with lib;
let cfg = config.lounge-rocks.nix-common;

in {

  options.lounge-rocks.nix-common = {
    enable = mkEnableOption "activate nix-common";
    disable-cache = mkEnableOption "not use binary-cache";
    disable-garbage-collection = mkEnableOption "disable garbage collection";

    min-free = mkOption {
      type = types.int;
      default = 5;
      description = "Garbage collect whenever there is less than x GiB left.";
    };
    max-free = mkOption {
      type = types.int;
      default = 10;
      description = "Garbage collect until there is at least x GiB left.";
    };

  };

  config = mkIf cfg.enable {

    # Install some basic utilities
    environment.systemPackages = with pkgs; [ git htop nil nix-top nixfmt nixpkgs-fmt ];

    nixpkgs.overlays = [
      attic.overlays.default
      # apps from external flakes
      (final: prev: { cachix = cachix.packages.${pkgs.system}.cachix; })
      # our packages are accessible via lounge-rocks.<name>
      self.overlays.default
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

        stalled-download-timeout = 10

        # these log lines are only shown on a failed build
        log-lines = 25

        # Free up to 10GiB whenever there is less than 5GiB left.
        min-free = ${toString (cfg.min-free * 1024 * 1024 * 1024)}
        max-free = ${toString (cfg.max-free * 1024 * 1024 * 1024)}
      '';
      settings = {
        # binary cache -> build by DroneCI
        substituters = mkIf (cfg.disable-cache != true) [
          "https://cache.lounge.rocks/nix-cache"
        ];
        trusted-public-keys = mkIf (cfg.disable-cache != true) [
          "nix-cache:4FILs79Adxn/798F8qk2PC1U8HaTlaPqptwNJrXNA1g="
        ];
        # Save space by hardlinking store files
        auto-optimise-store = true;
      };
      # Clean up old generations after 30 days
      # Should not be enabled for CI runners, since it will increase our S3 costs
      gc = mkIf (cfg.disable-garbage-collection != true) {
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

    system.stateVersion = "23.05";

  };
}
