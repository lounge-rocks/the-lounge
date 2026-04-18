{
  pkgs,
  lib,
  config,
  ...
}:
{

  clan.core.vars.generators.woodpecker-agent-envfile = {
    files.env = { };
  };

  lounge-rocks = {
    cloud-provider.proxmox.enable = true;
    nix-common.enable = true;
    tailscale.enable = true;
    users.MayNiklas.root = true;
    woodpecker = {
      docker-agent = {
        enable = true;
        envFile = config.clan.core.vars.generators.woodpecker-agent-envfile.files.env.path;
      };
      local-agent = {
        enable = true;
        envFile = config.clan.core.vars.generators.woodpecker-agent-envfile.files.env.path;
      };
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "woodpecker-agent-x86-2";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
