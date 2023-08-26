# the lounge - infrastructure

### Systems
| Machine                 | cloud        | platform | DNS entries                                                    | services                                 |
|-------------------------|--------------|----------|----------------------------------------------------------------|------------------------------------------|
| stuart                  | ORACLE CLOUD | ARM-64   | s3.lounge.rocks<br>minio.s3.lounge.rocks<br>cache.lounge.rocks | minio (S3)                               |
| oracle-aarch64-runner-1 | ORACLE CLOUD | ARM-64   | oracle-aarch64-runner-1.lounge.rocks                           | drone-exec-runner<br>drone-docker-runner |
| netcup-x86-runner-1     | netcup       | X86      | netcup-x86-runner-1.lounge.rocks                               | drone-exec-runner<br>drone-docker-runner |
| woodpecker-server       | Hetzner      | ARM-64   | build.lounge.rocks                                             | wodpecker-{server,agent,pipeliner}       |

### Using the binary cache
```nix
{ config, ... }: {
  nix = {
    trusted-public-keys = [ "nix-cache:4FILs79Adxn/798F8qk2PC1U8HaTlaPqptwNJrXNA1g=" ];
    substituters = [ "https://cache.lounge.rocks/nix-cache" ];
  };
}
```

### Using unstable channel

```sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update
```

## Initial Rebuild

```sh
nixos-rebuild switch --flake '.#stuart' --target-host root@s3.lounge.rocks --build-host root@s3.lounge.rocks
```

## Secrets

1. Get key for machine:

```
nix-shell -p ssh-to-age --run 'ssh-keyscan example.com | ssh-to-age'
```
2. Edit `.sops.yml`
3. Create `secrets/example.com` accordingly

