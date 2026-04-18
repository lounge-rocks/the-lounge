{
  meta.name = "the-lounge";

  inventory = {
    machines = {
      stuart.deploy.targetHost = "s3.lounge.rocks";
      woodpecker-server.deploy.targetHost = "build.lounge.rocks";
      woodpecker-agent-aarch64-1.deploy.targetHost = "oracle-aarch64-runner-1.lounge.rocks";
      woodpecker-agent-x86-1.deploy.targetHost = "192.168.40.2";
      woodpecker-agent-x86-2.deploy.targetHost = "100.101.16.26";
    };

    instances =
      let
        user-keys = import ./user-keys.nix;
      in
      {
        sshd.roles.server.tags.all = { };

        user-root-mayniklas = {
          module.name = "users";
          roles.default.tags = [ "all" ];
          roles.default.settings = {
            user = "root";
            share = true;
            openssh.authorizedKeys.keys = user-keys.ssh.mayniklas;
          };
        };

        user-root-pinpox = {
          module.name = "users";
          roles.default.machines.stuart = { };
          roles.default.machines.woodpecker-server = { };
          roles.default.settings = {
            user = "root";
            share = true;
            openssh.authorizedKeys.keys = user-keys.ssh.pinpox;
          };
        };

        # Import all modules from ./modules/ on all machines
        importer = {
          module.name = "importer";
          roles.default.tags.all = { };
          roles.default.extraModules = map (m: ./modules + "/${m}") (
            builtins.attrNames (builtins.readDir ./modules)
          );
        };
      };
  };

  vars.settings.secretStore = "age";
  vars.settings.recipients.default = (import ./user-keys.nix).age;
  secrets.age.plugins = [ "age-plugin-picohsm" ];
}
