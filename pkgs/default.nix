{ pkgs, ... }: {
  # our packages are accessible via lounge-rocks.<name>

  # woodpecker
  woodpecker-agent = pkgs.callPackage woodpecker/agent.nix { };
}
