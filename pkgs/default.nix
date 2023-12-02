inputs:
self: super: {

  # our packages are accessible via lounge-rocks.<name>
  lounge-rocks = {
    s3uploader = super.pkgs.callPackage ./s3uploader { };
    upload-nixos-iso = super.pkgs.callPackage ./upload-nixos-iso { };
    woodpecker-agent = super.pkgs.callPackage woodpecker/agent.nix { };
    woodpecker-cli = super.pkgs.callPackage woodpecker/cli.nix { };
    woodpecker-server = super.callPackage woodpecker/server.nix {
      woodpecker-frontend = super.callPackage woodpecker/frontend.nix { };
    };
  };

}
