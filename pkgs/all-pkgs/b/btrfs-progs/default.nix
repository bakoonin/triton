{ stdenv
, asciidoc
, docbook-xsl
, docbook_xml_dtd_45
, fetchurl
, libxslt
, xmlto

, acl
, attr
, e2fsprogs
, lzo
, util-linux_lib
, zlib
}:

let
  version = "4.9";

  tarballUrls = [
    "mirror://kernel/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "btrfs-progs-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "e227baeb4652e83aab33135ec29b30339e2c99bba67d56fb589cd8a6b642c8a3";
  };

  nativeBuildInputs = [
    asciidoc
    docbook-xsl
    docbook_xml_dtd_45
    libxslt
    xmlto
  ];

  buildInputs = [
    acl
    attr
    e2fsprogs
    lzo
    util-linux_lib
    zlib
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      pgpDecompress = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpKeyFingerprint = "F2B4 1200 C54E FB30 380C  1756 C565 D5F9 D76D 583B";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Utilities for the btrfs filesystem";
    homepage = https://btrfs.wiki.kernel.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms =  with platforms;
      x86_64-linux;
  };
}
