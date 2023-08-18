{ lib, fetchFromGitHub }:
let
  version = "0c282e86e8e9a477ea9ad52ee1c8348455189629";
  srcHash = "sha256-HLwndA88T5fh7s9+hb/mCNNGB8BBCZbSVMdq9ZB6UEM=";
  vendorHash = "sha256-HLwndA88T5fh7s9+hb/mCNNGB8BBCZbSVMdq9ZB6UEM=";
  yarnHash = "sha256-LhR+73Z2g92uOakYAN4ILTZ4yyUT5inviuTaOY6dcj8=";
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
