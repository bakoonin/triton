{ stdenv
, docbook-xsl
, doxygen
, fetchurl
, graphviz
, libxslt
, xmlto

, expat
, libffi
, libxml2

, enableDocumentation ? false
}:

let
  inherit (stdenv.lib)
    boolEn
    optionals;

  version = "1.14.0";
in
stdenv.mkDerivation rec {
  name = "wayland-${version}";

  src = fetchurl {
    url = "https://wayland.freedesktop.org/releases/${name}.tar.xz";
    multihash = "QmbHiXA1JkG8Cpw8CA83Ae7atdBUSyjniHgfA3JmMPmphy";
    hashOutput = false;
    sha256 = "ed80cabc0961a759a42092e2c39aabfc1ec9a13c86c98bbe2b812f008da27ab8";
  };

  nativeBuildInputs = [ ]
    ++ optionals enableDocumentation [
      docbook-xsl
      doxygen
      graphviz
      libxslt
      xmlto
    ];

  buildInputs = [
    expat
    libffi
    libxml2
  ];

  configureFlags = [
    "--enable-libraries"
    "--${boolEn enableDocumentation}-documentation"
  ];

  passthru = {
    inherit version;

    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "C722 3EBE 4EF6 6513 B892  5989 11A3 0156 E0E6 7611";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Reference implementation of the wayland protocol";
    homepage = https://wayland.freedesktop.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
