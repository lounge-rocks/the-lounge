{ pkgs, stdenv, ... }:
let
  s3uploader-skript = pkgs.writeShellScriptBin "s3uploader" ''
    for path in $(nix-store -qR $1); do
        # echo $path
      sigs=$(nix path-info --sigs --json $path | ${pkgs.jq}/bin/jq 'try .[].signatures[]')
      if [[ $sigs == *"cache.lounge.rocks"* ]]
      then
        echo "add $path to upload.list"
        echo $path >> upload.list
      fi
    done
    cat upload.list | uniq > upload
    nix copy --to 's3://nix-cache?scheme=https&region=eu-central-1&endpoint=s3.lounge.rocks&compression=zstd&parallel-compression=true' $(cat upload)
  '';
in
stdenv.mkDerivation {

  pname = "s3uploader";
  version = "0.1.0";

  # Needed if no src is used. Alternatively place script in
  # separate file and include it as src
  dontUnpack = true;

  installPhase = ''
    cp -r ${s3uploader-skript} $out
  '';
}
