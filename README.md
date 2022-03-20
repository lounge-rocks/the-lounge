# Oracle Cloud - ARMv8 Drone runner

### Installation:
1. Use the `Canonical-Ubuntu-20.04-aarch64-2022.03.02-0` image
2. Use nix infect: https://github.com/elitak/nixos-infect
3. Create a envfile: ‘/var/src/secrets/drone-ci/envfile'

### Using unstable channel
```bash
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
```
