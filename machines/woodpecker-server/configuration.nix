{ self, ... }:
{ pkgs, ... }: {

  lounge-rocks = {
    hetzner-x86.enable = true;
    nix-common.enable = true;
  };

  mayniklas = { user.root.enable = true; };
  pinpox = { services.openssh.enable = true; };

  networking = {
    hostName = "woodpecker-server";
    interfaces.ens3 = {
      ipv6.addresses = [{
        address = "2a01:4f8:1c1b:95a::";
        prefixLength = 64;
      }];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
  };

  system.stateVersion = "22.05";

}
