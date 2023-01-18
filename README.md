# the lounge - infrastructure

### Systems
| Machine                 | cloud        | platform | DNS entries                                                    | services                                 |
|-------------------------|--------------|----------|----------------------------------------------------------------|------------------------------------------|
| stuart                  | ORACLE CLOUD | ARM-64   | s3.lounge.rocks<br>minio.s3.lounge.rocks<br>cache.lounge.rocks | minio (S3)                               |
| oracle-aarch64-runner-1 | ORACLE CLOUD | ARM-64   | oracle-aarch64-runner-1.lounge.rocks                           | drone-exec-runner<br>drone-docker-runner |
| netcup-x86-runner-1     | netcup       | X86      | netcup-x86-runner-1.lounge.rocks                               | drone-exec-runner<br>drone-docker-runner |
| woodpecker-server       | Hetzner      | X86      | tba                                                            | dev                                      |



### Using the binary cache
```nix
{ config, ... }: {
  nix = {
    binaryCachePublicKeys =
      [ "cache.lounge.rocks:uXa8UuAEQoKFtU8Om/hq6d7U+HgcrduTVr8Cfl6JuaY=" ];
    binaryCaches =
      [ "https://cache.nixos.org" "https://cache.lounge.rocks?priority=50" ];
    trustedBinaryCaches =
      [ "https://cache.nixos.org" "https://cache.lounge.rocks" ];
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

