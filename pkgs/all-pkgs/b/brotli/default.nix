{ stdenv
, fetchurl

, version
}:

let
  sha256s = {
    "1.0.2" = "65bd21eca1532d7e18e22d733e1c604bfb1f51321712781bb7b81410ea77e35a";
    "1.0.3" = "0136ed31d129df55dc47eeb24c59336514ba72e1cced0973687a0c7b21a3ddf7";
  };
in
stdenv.mkDerivation {
  name = "brotli-${version}";

  src = fetchurl {
    url = "https://github.com/triton/brotli/releases/download/v${version}/brotli-${version}.tar.xz";
    hashOutput = false;
    sha256 = sha256s."${version}";
  };

  passthru = {
    inherit version;
  };

  meta = with stdenv.lib; {
    description = "A generic-purpose lossless compression algorithm and tool";
    homepage = https://github.com/google/brotli;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
