{ lib, config, modulesPath, disko, ... }:

with lib;

let

  # Recursively constructs an attrset of a given folder, recursing on directories, value of attrs is the filetype
  getDir = dir:
    mapAttrs
      (file: type: if type == "directory" then getDir "${dir}/${file}" else type)
      (builtins.readDir dir);

  # Collects all files of a directory as a list of strings of paths
  files = dir:
    collect isString
      (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  # Filters out directories that don't end with .nix or are this file, also makes the strings absolute
  validFiles = dir:
    map (file: ./. + "/${file}") (filter (file: hasSuffix ".nix" file && file != "default.nix") (files dir));

  cfg = config.lounge-rocks.cloud-provider;

in
{
  imports = validFiles ./. ++ [
    disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  options.lounge-rocks.cloud-provider = {
    enable = mkEnableOption "cloud-provider";
  };

  config = mkIf cfg.enable {

    # Running fstrim weekly is a good idea for VMs.
    # Empty blocks are returned to the host, which can then be used for other VMs.
    # It also reduces the size of the qcow2 image, which is good for backups.
    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Currently all our providers use KVM / QEMU
    services.qemuGuest.enable = true;

  };

}
