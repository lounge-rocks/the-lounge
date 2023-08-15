{ pkgs, ... }: {
  # our packages are accessible via lounge-rocks.<name>

  s3uploader = pkgs.callPackage ./s3uploader { };
  woodpecker-agent = pkgs.callPackage woodpecker/agent.nix { };

}
