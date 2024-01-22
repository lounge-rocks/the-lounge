{ lib, fetchFromGitHub }:
let
  version = "2.2.2";
  srcHash = "sha256-egPf5lY8TZJONfQhiWR9nLuuApmieZBXU15rfpQUbyM=";
  vendorHash = "sha256-ovsSYSavAjGb0zkRQFx1hRgyJJLBYIZlge/MU2ey+Ek=";
  yarnHash = "sha256-Bx4Z22JTF770rRAlFTSSfJ4FiwqngM57VCI1zAHciYc=";
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
