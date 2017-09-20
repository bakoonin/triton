{ stdenv
, fetchurl
, lib
, meson
, ninja
, python3Packages

, fuse_3
, glib
, openssh
}:

let
  version = "3.3.0";
in
stdenv.mkDerivation rec {
  name = "sshfs-${version}";

  src = fetchurl {
    url = "https://github.com/libfuse/sshfs/releases/download/${name}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "9ddfcc2564fafe002706b093b6295afbcb2cc0a3bc52bc805cc5361cb69ca51d";
  };

  nativeBuildInputs = [
    meson
    ninja
    python3Packages.docutils
  ];

  buildInputs = [
    fuse_3
    glib
    openssh
  ];

  postPatch = ''
    grep -q "'rst2man'" meson.build
    sed -i "s,'rst2man','rst2man.py',g" meson.build
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "ED31 791B 2C5C 1613 AF38  8B8A D113 FCAC 3C4E 599F";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
