{ stdenv
, autoconf
, automake
, fetchFromGitHub
, libtool
, which

, c-ares
, gperftools
, openssl
, protobuf-cpp
, zlib
}:

let
  version = "1.10.0";
in
stdenv.mkDerivation {
  name = "grpc-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "grpc";
    repo = "grpc";
    rev = "v${version}";
    sha256 = "48b5e25129861c062b4aeb9d524aea901c13bfb7b9585be954ae6fb99fbd0d6e";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    protobuf-cpp
    which
  ];

  buildInputs = [
    c-ares
    gperftools
    openssl
    protobuf-cpp
    zlib
  ];

  postPatch = ''
    rm -r third_party/{cares,protobuf,zlib,googletest,boringssl}
    unpackFile ${protobuf-cpp.src}
    mv -v protobuf* third_party/protobuf

    sed -i 's, -Werror,,g' Makefile
  '';

  NIX_CFLAGS_LINK = [
    "-pthread"
  ];

  preBuild = ''
    sed -i 's,\(grpc++.*\.so\.\)6,\11,g' Makefile
    makeFlagsArray+=("prefix=$out")
  '';

  postInstall = ''
    test -e "$out"/lib/libgrpc++.so.1
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
