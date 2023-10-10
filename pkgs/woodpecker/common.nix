{ lib, fetchFromGitHub }:
let
  version = "1c62f9f22e839d826b0ae24d83a8f6efcb8ce82c";
  srcHash = "sha256-xhvp58MSc1cieqMpjX6vm8lhE3AJRyEA+BlHYNA8BEY=";
  vendorHash = "sha256-RHHE/NB6mm1cOZGmsO2dPiTybFjyMXqP66D8za+YyIA=";
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
