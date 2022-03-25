# Oracle Cloud - ARMv8 Drone runner

### Installation:

```
# create instance
1. Create an instance (https://www.oracle.com/cloud/free)
2. Use the `Canonical-Ubuntu-20.04-aarch64-2022.03.02-0` image
3. Use 24GB RAM, 4 cores & 200GB storage

# get IPv6 to work
5. Networking -> Virtual Cloud Networks -> `your network`-> edit -> Enable enable IPv6 CIDR block
OR
5. Networking -> Virtual Cloud Networks -> `your network`-> CIDR Blocks -> add IPv6 CIDR Block
6. Networking -> Virtual Cloud Networks -> `your network`-> Route Tables -> default Route Table -> add ::/0 as Internet Gateway with target Internet Gateway
7. Networking -> Virtual Cloud Networks -> `your network`-> Subnet -> edit -> Enable enable IPv6 CIDR block
8. Networking -> Virtual Cloud Networks -> `your network`-> Subnet -> Security Lists -> Default Security List -> add IPv6 Ingress & Egress rules

# install NixOS
9. Use nix infect: https://github.com/elitak/nixos-infect
10. Create a envfile: ‘/var/src/secrets/drone-ci/envfile'
```

### Using unstable channel

```bash
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
```

# Initial Rebuild

```sh
nixos-rebuild switch --flake '.#stuart' --target-host root@s3.lounge.rocks --build-host root@s3.lounge.rocks
```
