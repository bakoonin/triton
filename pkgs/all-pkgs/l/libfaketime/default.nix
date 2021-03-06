{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libfaketime-0.9.6";

  src = fetchurl {
    url = "http://www.code-wizards.com/projects/libfaketime/${name}.tar.gz";
    sha256 = "1dw2lqsv2iqwxg51mdn25b4fjj3v357s0mc6ahxawqp210krg29s";
  };

  preBuild = ''
    grep -q '\-Werror' src/Makefile
    sed -i 's,-Werror,,g' src/Makefile

    makeFlagsArray+=(
      "PREFIX=$out"
      "LIBDIRNAME=/lib"
    )
  '';

  meta = with stdenv.lib; {
    description = "Report faked system time to programs without having to change the system-wide time";
    homepage = http://www.code-wizards.com/projects/libfaketime/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
