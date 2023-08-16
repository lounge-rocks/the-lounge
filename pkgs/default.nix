inputs:
self: super: {

  # our packages are accessible via lounge-rocks.<name>
  lounge-rocks = {
    s3uploader = super.pkgs.callPackage ./s3uploader { };
    woodpecker-agent = super.pkgs.callPackage woodpecker/agent.nix { };
  };

}
