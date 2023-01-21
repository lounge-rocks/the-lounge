{ lib, buildGoModule, pkgs, callPackage, makeWrapper, fetchFromGitHub, woodpecker-plugin-git }:
buildGoModule {
  pname = "woodpecker-plugin-git";
  name = "woodpecker-plugin-git";
  vendorSha256 = "sha256-63Ly/9yIJu2K/DwOfGs9pYU3fokbs2senZkl3MJ1UIY=";

  src = woodpecker-plugin-git;

  # ldflags = [
  #   "-s"
  #   "-w"
  #   "-X github.com/woodpecker-ci/woodpecker/version.Version=${version}"
  # ];

  doCheck = false;

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/plugin-git \
      --set PATH ${lib.makeBinPath [
        pkgs.git-lfs
        pkgs.git
        pkgs.coreutils-full
        pkgs.findutils
        pkgs.gnumake
        pkgs.gnused
        pkgs.gnugrep
      ]}
  '';

  # subPackages = "cmd/agent";

  CGO_ENABLED = 0;

}
