{ lib, fetchFromGitHub }:
let
  version = "839c3b8a6d93714f3b3232308f2913cae212dedb";
  srcHash = "sha256-nTFfhSMRbGhGRxRRKpaqCIdYtfRnIRKxLmRd+Jahw2o=";
  vendorHash = "sha256-fMXn3wZehJi1O+T9XP6ijah+OKHnp6k9DMtGB7CZosc=";
  yarnHash = "sha256-sG0sblZKz4qR3PmK1pHHrgiaWEUHadNKEDuhYkLI9OA=";
in
{
  inherit version yarnHash vendorHash;

  src = fetchFromGitHub {
    owner = "woodpecker-ci";
    repo = "woodpecker";
    rev = "${version}";
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
    "-X github.com/woodpecker-ci/woodpecker/version.Version=${version}"
  ];

  meta = with lib; {
    homepage = "https://woodpecker-ci.org/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ambroisie techknowlogick adamcstephens ];
  };
}
