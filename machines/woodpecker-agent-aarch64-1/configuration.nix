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
    cloud-provider.oracle.enable = true;
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

  networking = {
    domain = "lounge.rocks";
    hostName = "woodpecker-agent-aarch64-1";
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
