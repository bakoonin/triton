{ stdenv, fetchurl, pythonPackages }:

stdenv.mkDerivation rec {
  version = "2.6";
  release = ".0";
  name = "bazaar-${version}${release}";

  src = fetchurl {
    url = "http://launchpad.net/bzr/${version}/${version}${release}/+download/bzr-${version}${release}.tar.gz";
    sha256 = "1c6sj77h5f97qimjc14kr532kgc0jk3wq778xrkqi0pbh9qpk509";
  };

  buildInputs = [ pythonPackages.python pythonPackages.wrapPython ];

  # Bazaar can't find the certificates alone
  patches = [ ./add_certificates.patch ];
  postPatch = ''
    substituteInPlace bzrlib/transport/http/_urllib2_wrappers.py \
      --subst-var-by certPath /etc/ssl/certs/ca-certificates.crt
  '';

  installPhase = ''
    python setup.py install --prefix=$out
    wrapPythonPrograms
  '';

  meta = {
    homepage = http://bazaar-vcs.org/;
    description = "A distributed version control system that Just Works";
    platforms = stdenv.lib.platforms.unix;
  };
}
