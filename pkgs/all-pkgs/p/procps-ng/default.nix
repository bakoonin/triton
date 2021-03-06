{ stdenv
, fetchurl

, ncurses
}:

let
  version = "3.3.13";
in
stdenv.mkDerivation rec {
  name = "procps-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/procps-ng/Production/procps-ng-${version}.tar.xz";
    hashOutput = false;
    sha256 = "52b05b2bd5b05f46f24766a10474337ebadd828df9915e2b178df291cf88f7d3";
  };

  buildInputs = [
    ncurses
  ];

  makeFlags = [
    "usrbin_execdir=$(out)/bin"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "5D2F B320 B825 D939 04D2  0519 3938 F96B DF50 FEA5";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://sourceforge.net/projects/procps-ng/;
    description = "Utilities that give information about processes using the /proc filesystem";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
