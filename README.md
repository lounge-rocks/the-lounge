# the lounge - infrastructure

Managed with [clan](https://clan.lol).

### Systems

| Machine                      | Cloud        | Platform | DNS entries                              | Services                                   |
| ---------------------------- | ------------ | -------- | ---------------------------------------- | ------------------------------------------ |
| stuart                       | Oracle Cloud | ARM-64   | s3.lounge.rocks<br>minio.s3.lounge.rocks | MinIO (S3), nix cache proxy                |
| woodpecker-server            | Hetzner      | ARM-64   | build.lounge.rocks<br>cache.lounge.rocks | woodpecker-server, attic cache             |
| woodpecker-agent-aarch64-1   | Oracle Cloud | ARM-64   | oracle-aarch64-runner-1.lounge.rocks     | woodpecker-agent                           |
| woodpecker-agent-x86-1       | Proxmox PVE  | X86      |                                          | woodpecker-agent                           |
| woodpecker-agent-x86-2       | Proxmox PVE  | X86      |                                          | woodpecker-agent                           |

### Using the binary cache

```nix
{ config, ... }: {
  nix = {
    trusted-public-keys = [ "nix-cache:4FILs79Adxn/798F8qk2PC1U8HaTlaPqptwNJrXNA1g=" ];
    substituters = [ "https://cache.lounge.rocks/nix-cache" ];
  };
}
```

### Deployment

Update a single machine:

```sh
clan machines update stuart
```

Update all machines:

```sh
clan machines update
```

Build locally and deploy to remote:

```sh
clan machines update stuart --build-host localhost
```

### Secrets

Secrets are managed with clan vars using the age backend. Admin age keys are
defined in `user-keys.nix`.

See the [clan vars
documentation](https://clan.lol/docs/25.11/guides/vars/vars-backend/) for usage.
