{ config, pkgs, lib, ... }:
with lib;
let cfg = config.lounge-rocks.users; in
{

  options.lounge-rocks.users = {
    MayNiklas.root = mkEnableOption "MayNiklas root access";
    pinpox.root = mkEnableOption "pinpox root access";
  };

  config = {

    # enable ZSH with autosuggestions and completion
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
    };

    users = {
      defaultUserShell = pkgs.zsh;
      users.root = {
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [ ] ++
          lib.optionals cfg.MayNiklas.root [
            # MayNiklas keys
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXZFusz81OwV8tiQjhvUMaXu3D8YfB8c375k5pIbwLWBi6Ouzp9MvNO1dNldrI6r2cmeeJH5pbnwsnzlUrYyoP/mb1cYfC9KqejrPySor9407RFQyYd738fs9wS2Mpak8VcoGH1LX0RD+JrVrVvUd6VVnKdmXeuZsv3IXDiGMH7HN6WOVuE5Y7fgBUNWmKROInR28aWTJc1sLN5ad85Z1suKIFqVR2FIjce1HsOyq7AIuJqgp5GOz5R7z2d30iziCo+r8vonABqdmsFUUR4tXoWD6S0VR6bfK12KnJfg4hSGYkNb85VQwS1BFaVnk+Nx1rRmSwFLQiJfFxRmGF6paMmCNoZ5m5AloVgpgcmDbgWoYSiLebN+sE8wEk7hVoht3SowSKBjBT8BJwg+hqBEhAfL1IgRJZwivzBdb7OQ5K8l3JiZjoM4Xg2HAcEsWNpmpNK+l6tRvlv2L/dQPtoky712Yh7lpX5dI5sSNAdIVgvtker4+D1LWmcVkDCg9bvYKckPLL+zJpeqbgSp0UoUqPBrmDxFmcmMKC0mOEKrMMpwEsgZZAnzDznJvqEFOFHsXy4U2WPBywXN7geoeABbUDbmw8sgDTEzPnemqrHng8UbhuQ7HcWHUqZTqlg99U5XnDQrxw5UkORZ3d3m9fiAvsOfDaar6/qWS+6If69x3CmQ=="
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBuR+Lab+8+LplHecvF+KCVKM+oLo15fLV77OLbFPQOka09ur2f2/Z+KvE+N+uxetp0yQiG1/QY0gfrNquaC1P3HzgKYI+UdPEDHaava343tWxUJGuYqxPVrfj0yQfgt9p+tDrqzKsTgdu8AOv0s2jiEawSfAOoBbjCcmeEJIkk0BAHP2Xzuf5D8rLP5d3UcMH4nLSJwoJPXKEG2Yb3OjKde4iZ4NmJ7L/Y1bTMvN2k2cZDLi+AOvvC2ddU42LkFbWBc651LatPS90VRyO6XRKZzHkkhKU8EA6Qg/inE8IBGksj9cIwSfictyqXwDWIibM+CGegYdY7/fgyjd1XMO8sDbNtmcLilKmPlWoeeRxYyYnSYt5TPkdVL+zaZH/VY4MFpDcOARtuCd44vPH2+BlSct9mkNgx15at89foXOsvUdHnZdNZioDsq5it339x0Q6gR056E/B7tqLTb+TbmO/kumARiRAxZiIAtpe7FK3q+xSXO+xAhiHRSqnD2GV5LmnKHm0uhoO1AwkNlDQoXsXuGNLXE56z2uI1SPysHySap48QnpB7R9xzoHilj4joLt68KNEebwcaHuFx4rl5ziu/v1z0vnQtK3JrbKQ3qFBPwwZpdiurFh9ah+yLA5Bz4tuFpVagHxHiQehzBx9E57N084ISSe21u55mxG7t2kJDQ=="
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTN6R5IKYsOd4AlT0Ly+GPBwpfUBosuPZzgRMtOVGNR2ONcVGQHIx50N+FttsROjRIj3WqnnKoPGcy4wrRskpiK9G0tbU73qDRoWCnghcGQDfLO4BA+lW+U5HZ/EbHcCx9FSO6xkWWToWnXV37A5L3xdxGxBrsGqYFQUcmoxfGamaFQlaqnqHrtK209OTeyBIEdSr5NrI2BzQEvSIk4hFdS4AiCLUD/EnCj35Frle14cOzIU2dh3sLpULzfdTD/U43Kyt0NPGFqNX0KS/NjlT75eM6QpkgnKpb0W3QPaioIil0Vkwym2CJBCIJ65kZbhd2NiK7vCVQPEHdeIoCw2S/N1ggPpdUBOutoefWnx4RZ1Y+jYIQu+3sXETqZJ0G5b5nU2FDs5G+izlMxlRbhoUJlnf1ZMa4U6SQIgVnO/l7HOhcMjeNlbEGH+VXJacccDFQ6AjIj3V8rAMh4YecLpEhiP2XdD0dla1UPlU1HpifRoxTJ506+eIfPIkmlnMuyyIQRVwliX+QnACqb9B//xgi9vFQHEYIyKrwud7W/+5MckQNRx1IGEJHjVs7xZE+3j3kF0o+MjGcjJWnV+R8KxPj5qb4twr3z3SDrIZ766DwzLSQ1YVskU9l7Ko9SfELvZKUVmW7nHZxZ61MJYOU3Nrol0MMRe2xr6Asn2/5vpJ4nQ=="
          ] ++ lib.optionals cfg.pinpox.root [
          # pinpox keys
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSJJs01RqXS6YE5Jf8LUJoJVBxFev3R18FWXJyLeYJE cardno:22_412_951"
        ];
      };
    };

  };
}
