{ stdenv
, fetchurl
, lib
, python2

, icu
, libidn2
, libunistring
}:

let
  version = "0.20.1";
in
stdenv.mkDerivation rec {
  name = "libpsl-${version}";

  src = fetchurl {
    url = "https://github.com/rockdaboot/libpsl/releases/download/${name}/"
      + "${name}.tar.gz";
    sha256 = "95199613158dd773257ef4feccf1acdf5f791479ab4537bd984ca8598447219f";
  };

  nativeBuildInputs = [
    python2
  ];

  buildInputs = [
    icu
    libidn2
    libunistring
  ];

  postPatch = ''
    patchShebangs src/psl-make-dafsa
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
