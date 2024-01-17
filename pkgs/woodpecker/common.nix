{ lib, fetchFromGitHub }:
let
  version = "2.1.1";
  srcHash = "sha256-rDnfJ7tNf5fBIpP69R2uLCfPC+zYO/CKJL6fsdX9pIQ=";
  vendorHash = "sha256-hFf2vjefum+pdA7BR+4nFmqrPKOkPqij2KFLX+ew+4U=";
  yarnHash = "sha256-XouDPWizy5TPfttyq93AqIsz9j6NRL4B1z8xNfI1IKs=";
in
{
  inherit version yarnHash vendorHash;

  src = fetchFromGitHub {
    owner = "woodpecker-ci";
    repo = "woodpecker";
    rev = "v${version}";
    hash = srcHash;
  };

  postInstall = ''
    cd $out/bin
    for f in *; do
      mv -- "$f" "woodpecker-$f"
    done
    cd -
  '';

  ldflags = [
    "-s"
    "-w"
    "-X go.woodpecker-ci.org/woodpecker/version.Version=${version}"
  ];

  meta = with lib; {
    homepage = "https://woodpecker-ci.org/";
    changelog = "https://github.com/woodpecker-ci/woodpecker/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = with maintainers; [ ambroisie techknowlogick adamcstephens ];
  };
}
