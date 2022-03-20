{ config, pkgs, lib, modulesPath, ... }:

with lib;
let cfg = config.lounge-rocks.oracle-aarch64;

in {

  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  options.lounge-rocks.oracle-aarch64 = {
    enable = mkEnableOption "activate oracle-aarch64";
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
        # Free up to 1GiB whenever there is less than 100MiB left.
        min-free = ${toString (100 * 1024 * 1024)}
        max-free = ${toString (1024 * 1024 * 1024)}
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

    boot = {
      loader.grub = {
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "nodev";
      };
      cleanTmpDir = true;
      initrd.kernelModules = [ "nvme" ];
    };
    zramSwap.enable = true;

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-label/UEFI";
        fsType = "vfat";
      };
      "/" = {
        device = "/dev/disk/by-label/cloudimg-rootfs";
        fsType = "ext4";
      };
    };
  };
}
