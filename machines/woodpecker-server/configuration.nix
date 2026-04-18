{
  pkgs,
  lib,
  config,
  ...
}:
{

  clan.core.vars.generators.woodpecker-server-envfile = {
    files.env = { };
  };
  clan.core.vars.generators.woodpecker-agent-envfile = {
    files.env = { };
  };
  clan.core.vars.generators.woodpecker-attic-envfile = {
    files.env = { };
  };

  lounge-rocks = {
    users = {
      MayNiklas.root = true;
      pinpox.root = true;
    };
    cloud-provider.hetzner = {
      enable = true;
      interface = "enp1s0";
      ipv6_address = "2a01:4f8:1c17:636f::";
    };
    attic = {
      enable = true;
      scaling-factor = 64;
      # 365 days retention (created cache on 25st October 2023)
      retention-period = 365 * 24 * 60 * 60;
      envFile = config.clan.core.vars.generators.woodpecker-attic-envfile.files.env.path;
    };
    nginx.geoIP = true;
    nix-common.enable = true;
    tailscale.enable = true;
    # woodpecker.pipeliner.enable = true; # TODO fix
    woodpecker.server = {
      enable = true;
      envFile = config.clan.core.vars.generators.woodpecker-server-envfile.files.env.path;
    };
    woodpecker.log = "trace";
  };

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    domain = "lounge.rocks";
    hostName = "woodpecker-server";
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

}
