{ pkgs, stdenv, ... }:
let
  NixOS-ISO = pkgs.fetchurl {
    url = "https://releases.nixos.org/nixos/23.11/nixos-23.11.928.50aa30a13c4a/nixos-minimal-23.11.928.50aa30a13c4a-x86_64-linux.iso";
    sha256 = "0kb0w5qdlhs7f08rnn8vcbk0gja4wjcgr3xw8572q70lzk6dg8z6";
  };
  upload-nixos-iso-skript = pkgs.writeShellScriptBin "upload-nixos-iso" ''
    export targetIP=46.38.225.190
    export sftp_user=94588
    export sftp_port=2222

    # Upload ISO
    echo "Uploading ${NixOS-ISO} to $targetIP using user $sftp_user and port $sftp_port"
    scp -P $sftp_port ${NixOS-ISO} $sftp_user@$targetIP:/cdrom/
  '';
in
stdenv.mkDerivation {

  pname = "upload-nixos-iso";
  version = "0.1.0";

  # Needed if no src is used. Alternatively place script in
  # separate file and include it as src
  dontUnpack = true;

  installPhase = ''
    cp -r ${upload-nixos-iso-skript} $out
  '';
}
