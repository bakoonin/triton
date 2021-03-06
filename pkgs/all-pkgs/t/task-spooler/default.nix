{ stdenv
, fetchurl
, lib
, makeWrapper
}:

stdenv.mkDerivation rec {
  name = "ts-1.0";

  src = fetchurl {
    url = "http://vicerveza.homeunix.net/~viric/soft/ts/${name}.tar.gz";
    multihash = "Qma4Agj6wjTszJetfNTPx3Q1o8mrN7sZSJVeGep8jADDhZ";
    sha256 = "4f53e34fff0bb24caaa44cdf7598fd02f3e5fa7cacaea43fa0d081d03ffbb395";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  preFixup = ''
    mv -v "$out/bin/ts" "$out/bin/task-spooler"
    ln -sv "$out/bin/task-spooler" "$out/bin/ts"
    rm -rvf "$out/share"
  '' + ''
    wrapProgram $out/bin/task-spooler \
      --set 'XDG_CACHE_HOME' '"''${XDG_CACHE_HOME:-$HOME/.cache}"' \
      --set 'XDG_DATA_HOME' '"''${XDG_DATA_HOME:-$HOME/.local/share}"' \
      --set 'TS_SOCKET' '"''${TS_SOCKET:-$XDG_CACHE_HOME/task-spooler.socket}"' \
      --set 'TS_SAVELIST' '"''${TS_SAVELIST:-$XDG_DATA_HOME/.local/share/tast-spooler/savelist}"' \
      --set 'TS_SLOTS' '"''${TS_SLOTS:-1}"' \
      --run '
        if [ ! -d "$(dirname "$TS_SOCKET")" ] ; then
          mkdir -p "$(dirname "$TS_SOCKET")"
        fi
        if [ ! -f "$TS_SOCKET" ] ; then
          touch "$TS_SOCKET"
        fi
        if [ ! -d "$(dirname "$TS_SAVELIST")" ] ; then
          mkdir -p "$(dirname "$TS_SAVELIST")"
        fi
        if [ ! -f "$TS_SAVELIST" ] ; then
          touch "$TS_SAVELIST"
        fi
      '

  '';

  meta = with lib; {
    description = "A comfortable way of running batch jobs";
    homepage = http://vicerveza.homeunix.net/~viric/soft/ts/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
