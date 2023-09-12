# This is just pulled from https://github.com/NixOS/nixpkgs/pull/150130/
{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  name = "guix-binary-${version}";
  version = "1.4.0";

  src = fetchurl {
    url =
      "https://ftp.gnu.org/gnu/guix/guix-binary-${version}.${stdenv.targetPlatform.system}.tar.xz";
    sha256 = {
      "x86_64-linux" = "1jfr1rkbzm26dmy3rkxln6ydwvwxpk2zq919dhwiz2wmqp4sfv13";
      "i686-linux" = "0bfh1w2nhcykqzz9h3m2cyzgawxwy5digggfjkprg0182zlj8q8y";
      "aarch64-linux" = "1x7wxc41w41is6zsfblln3k5b595bb2355pcnx09k4c950whgn3j";
    }."${stdenv.targetPlatform.system}";
  };
  sourceRoot = ".";

  outputs = [ "out" "store" "var" ];
  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    # copy the /gnu/store content
    mkdir -p $store
    cp -r gnu $store

    # copy /var content
    mkdir -p $var
    cp -r var $var

    # Unfortunately, packages without $out can have difficulties.
    # We'll use a hacky workaround for now by linking the binary with the binary from the Guix root profile.
    mkdir -p $out/bin
    ln -sf /var/guix/profiles/per-user/root/current-guix/bin/guix $out/bin
    ln -sf /var/guix/profiles/per-user/root/current-guix/bin/guix-daemon $out/bin
  '';

  setOutputFlags = false;

  meta = {
    description = "The GNU Guix package manager";
    homepage = "https://www.gnu.org/software/guix/";
    license = lib.licenses.gpl3Plus;
    platforms = [ "aarch64-linux" "i686-linux" "x86_64-linux" ];
    outputsToInstall = [ ];
  };
}
