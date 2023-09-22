{ lib
, buildGuileModule

# !!! Why disarchive can't build?
#, disarchive
, guile-lzma
, scheme-bytestructures
, guile-avahi
, guile-gcrypt
, guile-git
, guile-gnutls
, guile-json
, guile-lzlib
, guile-semver
, guile-sqlite3
, guile-ssh
, guile-zlib
, guile-zstd
, guile3-lib

, fetchgit
, pkg-config
, makeWrapper
, help2man
, bzip2
, gzip
, libgcrypt
, sqlite
, autoconf-archive
, autoreconfHook
, texinfo
, locale
, perlPackages
, gettext
, glibcLocales

, confDir ? "/etc"
, stateDir ? "/var"
, storeDir ? "/gnu/store"
}:

let
  rev = "8e2f32cee982d42a79e53fc1e9aa7b8ff0514714";
in
buildGuileModule rec {
  pname = "guix";
  version = "1.4.0";

  src = builtins.fetchTarball {
    url = "https://ftpmirror.gnu.org/gnu/guix/guix-1.4.0.tar.gz";
    sha256 = "sha256:1rnnyn6vxbcx0xicsf4kh889lxp2ksi1m983jcdi6a62wdb1mqqj";
  };

  preAutoreconf = ''
    ./bootstrap
  '';

  propagatedBuildInputs = [
    #disarchive
    guile-lzma
    scheme-bytestructures
    guile-avahi
    guile-gcrypt
    guile-git
    guile-gnutls
    guile-json
    guile-lzlib
    guile-semver
    guile-sqlite3
    guile-ssh
    guile-zlib
    guile-zstd
    guile3-lib
  ] ++ [
    gzip
    bzip2
    libgcrypt
    sqlite
  ];

  nativeBuildInputs = [
    pkg-config
    glibcLocales
    makeWrapper
    gettext
    autoreconfHook
  ];

  buildInputs = [
    help2man
    autoconf-archive
    texinfo
    locale
    perlPackages.Po4a
  ];
  enableParallelBuilding = true;

  configureFlags = [
    "--with-store-dir=${storeDir}"
    "--localstatedir=${stateDir}"
    "--with-channel-commit=${rev}"
    "--sysconfdir=${confDir}"
    "--with-bash-completion-dir=${placeholder "out"}/etc/bash_completion.d"
  ];

  patches = [ ./0001-remove-test-mail.scm.patch ];

  postPatch = ''
    sed nix/local.mk -i -E \
      -e 's|^sysvinitservicedir = .*$|sysvinitservicedir = ${placeholder "out"}/etc/init.d|' \
      -e 's|^openrcservicedir = .*$|openrcservicedir = ${placeholder "out"}/etc/openrc|'
  '';

  # We will start to look into checking once the dependencies are properly installed.
  doCheck = false;

  meta = with lib; {
    description =
      "A transactional package manager for an advanced distribution of the GNU system";
    homepage = "https://guix.gnu.org/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
