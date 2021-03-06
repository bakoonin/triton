{ stdenv
, fetchurl
, gettext
, lib
, texinfo

, bzip2
, gnutls
, libassuan
, libgcrypt
, libgpg-error
, libksba
, libusb
, npth
, openldap
, pcsc-lite_lib
, readline
, sqlite
, zlib
}:

let
  inherit (lib)
    elem
    optional
    optionals
    platforms
    versionAtLeast
    versionOlder;

  tarballUrls = version: [
    "mirror://gnupg/gnupg/gnupg-${version}.tar.bz2"
  ];

  version = "2.2.6";
in
stdenv.mkDerivation rec {
  name = "gnupg-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "e64d8c5fa2d05938a5080cb784a98ac21be0812f2a26f844b18f0d6a0e711984";
  };

  nativeBuildInputs = [
    gettext
    texinfo
  ];

  buildInputs = [
    bzip2
    gnutls
    libassuan
    libgcrypt
    libgpg-error
    libksba
    libusb
    npth
    openldap
    readline
    sqlite
    zlib
  ];

  postPatch = ''
    sed -i 's,"libpcsclite\.so[^"]*","${pcsc-lite_lib}/lib/libpcsclite.so",g' scd/scdaemon.c
  '';

  preConfigure = ''
    export CPPFLAGS="$CPPFLAGS -I$(echo "${libusb}"/include/*)"
  '';

  configureFlags = [
    "--with-pinentry-pgm=pinentry"
    "--disable-selinux-support"
    "--disable-gpg-idea"
    "--disable-gpg-cast5"
    "--disable-gpg-md5"
    "--enable-zip"
    "--enable-bzip2"
    "--with-capabilities"
    "--enable-card-support"
    "--enable-ccid-driver"
    "--enable-sqlite"
    "--disable-ntbtls"
    "--enable-gnutls"
    # "--with-adns"  # This seems to be buggy
    "--enable-ldap"
    "--with-mailprog=sendmail"
    "--with-zlib"
    "--with-bzip2"
    "--enable-optimization"
    "--disable-build-timestamp"
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.2.6";
      pgpsigUrl = map (n: "${n}.sig") urls;
      pgpKeyFingerprints = [
        "D869 2123 C406 5DEA 5E0F  3AB5 249B 39D2 4F25 E3B6"
        "46CC 7308 65BB 5C78 EBAB  ADCF 0437 6F3E E085 6959"
        "031E C253 6E58 0D8E A286  A9F2 2071 B08A 33BD 3F06"
        "D238 EA65 D64C 67ED 4C30  73F2 8A86 1B1C 7EFD 60D9"
        "46CC 7308 65BB 5C78 EBAB  ADCF 0437 6F3E E085 6959"
      ];
      sha256 = "e64d8c5fa2d05938a5080cb784a98ac21be0812f2a26f844b18f0d6a0e711984";
    };
  };

  meta = with lib; {
    homepage = http://gnupg.org;
    description = "a complete and free implementation of the OpenPGP standard";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
