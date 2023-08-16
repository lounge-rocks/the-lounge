{ lib, fetchFromGitHub }:
let
  version = "f2e31c67701d0a64b042bcbc688a03f8e01fd15c";
  srcHash = "sha256-xm3PFgPvFa9Aei8rgGBLcLt/0I/muV5EpqoNtPpgqis=";
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
