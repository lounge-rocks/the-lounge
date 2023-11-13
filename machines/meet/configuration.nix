# nix run github:numtide/nixos-anywhere -- --flake .#meet root@meet.lounge.rocks
{ self, ... }:
{ pkgs, lib, config, ... }:
{

  imports = [ ./jitsi.nix ];

  lounge-rocks.jitsi.enable = true;
  lounge-rocks.nginx.enable = true;

  lounge-rocks = {
    users = { MayNiklas.root = true; };
    cloud-provider.hetzner = {
      enable = true;
      interface = "ens3";
      ipv6_address = "2a01:4f8:1c1e:864f::1";
    };
    nix-common.enable = true;
  };

  networking = {
    firewall.allowedTCPPorts = [ 22 ];
    hostName = "meet";
    domain = "lounge.rocks";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSPFCTMxX+40P6utWieGyOOOIkwlMc62+jmBx0FMIBb5MOXPSHTsrvOx6eQZAc4nNR2HVAzpCBX5wOvBhgNRshJE7P58pzzIUNv18waGyD97e9Sv7f/Vfom7MvQ/LzgO/fbhrfAPt/Zg/GQzAPzPLyZ51vnwsv7hTB8eCtVvBnG0+4rKrazKpM/Cyz1OW9UpdnP/yzApeXqWItdT8qkGat6i6N4witr5BWj+ifGiJpXij+zIGlT8aTTG1hHGqhpZC28p4fjWyMBqFZ4rCx4AHsg5Cm7RvddtFihaVOXjKVTnrbYz4HXf0bbkmbkLUtBxcFizDhnhFs7v7KMv6XGjYUfcwHceywusrgtTU4m6+gcHK1h6wm49qrBGWUvvr2XghusIm92px9MVhpr05Rjz1xu5BSYXTGEjln2gas+y6aXRs/6zQvRWN8s/T57EbXd5VnYJmkueSMtbmAnc2XNcRX6sucthKrO8KgHrgZAezbx3f5HrPqPEr+9HykIICKWlGnARHstE1vXWZGHVWUDMJNtgXjhjCpldHotmDygm9+8I+SqJTlxCbticxclqUbucaXa/BD1oa3uelM1apOWnC1pZgfEinDevtm0OjwKPALKPK+/FFtoNDLotYztV0lcfU3sH+yN4bM8gHHd72N4E1YHPnamyL8LyiKuedbReOmcQ== nik@kora"
  ];

  # nix run .\#lollypops -- meet:rebuild
  lollypops.deployment = {
    local-evaluation = true;
    ssh = { user = "root"; host = "${config.networking.fqdn}"; };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

}
