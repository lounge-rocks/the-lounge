{ lib, fetchFromGitHub }:
let
  version = "1f956753659204d46d834ac3d0cb68fd71a5b941";
  srcHash = "sha256-3RD8FecSMQHUzN8FHUhw+G6zxX4b603IsVvDi+bKNRw=";
  vendorHash = "sha256-nSKZTL6YbGma5xB78e5eKrfat3VHK9eVb81yevQkh4g=";
  yarnHash = "sha256-QNeQwWU36A05zaARWmqEOhfyZRW68OgF4wTonQLYQfs=";
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
