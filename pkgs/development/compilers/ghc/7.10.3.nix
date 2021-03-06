{ stdenv, fetchurl, fetchpatch, ghc, perl, gmp, ncurses, binutils, coreutils
, libxml2, libxslt, docbook-xsl, docbook_xml_dtd_45, docbook_xml_dtd_42, hscolour
}:

let

  docFixes = fetchurl {
    url = "https://downloads.haskell.org/~ghc/7.10.3/ghc-7.10.3a.patch";
    sha256 = "1j45z4kcd3w1rzm4hapap2xc16bbh942qnzzdbdjcwqznsccznf0";
  };

in

stdenv.mkDerivation rec {
  version = "7.10.3";
  name = "ghc-${version}";

  src = fetchurl {
    url = "https://downloads.haskell.org/~ghc/${version}/${name}-src.tar.xz";
    sha256 = "1vsgmic8csczl62ciz51iv8nhrkm72lyhbz7p7id13y2w7fcx46g";
  };

  patches = [
    docFixes
    ./dont-pass-linker-flags-via-response-files.patch   # https://github.com/NixOS/nixpkgs/issues/10752
  ];

  buildInputs = [ ghc perl libxml2 libxslt docbook-xsl docbook_xml_dtd_45 docbook_xml_dtd_42 hscolour ];

  enableParallelBuilding = true;

  preConfigure = ''
    export LD_LIBRARY_PATH="${gmp}/lib:${stdenv.libc}/lib"
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $out/lib/ghc-${version}"
  '';

  configureFlags = [
    "--with-gcc=${stdenv.cc}/bin/cc"
    "--with-gmp-includes=${gmp}/include" "--with-gmp-libraries=${gmp}/lib"
    "--with-curses-includes=${ncurses}/include" "--with-curses-libraries=${ncurses}/lib"
  ];

  # required, because otherwise all symbols from HSffi.o are stripped, and
  # that in turn causes GHCi to abort
  stripDebugFlags = [ "-S" "--keep-file-symbols" ];

  postInstall = ''
    # Install the bash completion file.
    install -D -m 444 utils/completion/ghc.bash $out/share/bash-completion/completions/ghc

    # Patch scripts to include "readelf" and "cat" in $PATH.
    for i in "$out/bin/"*; do
      test ! -h $i || continue
      egrep --quiet '^#!' <(head -n 1 $i) || continue
      sed -i -e '2i export PATH="$PATH:${binutils}/bin:${coreutils}/bin"' $i
    done
  '';

  # FIXME
  buildDirCheck = false;

  meta = {
    homepage = "http://haskell.org/ghc";
    description = "The Glasgow Haskell Compiler";
    maintainers = with stdenv.lib.maintainers; [ marcweber andres simons ];
    inherit (ghc.meta) license platforms;
  };

}
