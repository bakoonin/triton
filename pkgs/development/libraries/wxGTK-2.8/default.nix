{ stdenv, fetchurl, pkgconfig, gtk2, xorg
, gstreamer, gst-plugins-base_0, GConf
, withMesa ? true, mesa ? null, compat24 ? false, compat26 ? true, unicode ? true,
}:

assert withMesa -> mesa != null;

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "2.8.12.1";
  name = "wxGTK-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/wxpython/wxPython-src-${version}.tar.bz2";
    sha256 = "1l1w4i113csv3bd5r8ybyj0qpxdq83lj6jrc5p7cc10mkwyiagqz";
  };

  buildInputs = [
    gtk2 xorg.Xxf86vm xorg.xf86vidmodeproto
    gstreamer gst-plugins-base_0 GConf ]
    ++ optional withMesa mesa;

  nativeBuildInputs = [ pkgconfig ];

  configureFlags = [
    "--enable-gtk2"
    (if compat24 then "--enable-compat24" else "--disable-compat24")
    (if compat26 then "--enable-compat26" else "--disable-compat26")
    "--disable-precomp-headers"
    (if unicode then "--enable-unicode" else "")
    "--enable-mediactrl"
    "--enable-graphics_ctx"
  ] ++ optional withMesa "--with-opengl";

  # These variables are used by configure to find some dependencies.
  SEARCH_INCLUDE =
    "${xorg.libXinerama}/include ${xorg.libSM}/include ${xorg.libXxf86vm}/include";
  SEARCH_LIB =
    "${xorg.libXinerama}/lib ${xorg.libSM}/lib ${xorg.libXxf86vm}/lib "
    + optionalString withMesa "${mesa}/lib ";

  # Work around a bug in configure.
  NIX_CFLAGS_COMPILE = "-DHAVE_X11_XLIB_H=1";

  preConfigure = "
    substituteInPlace configure --replace 'SEARCH_INCLUDE=' 'DUMMY_SEARCH_INCLUDE='
    substituteInPlace configure --replace 'SEARCH_LIB=' 'DUMMY_SEARCH_LIB='
    substituteInPlace configure --replace /usr /no-such-path
  ";

  postBuild = "(cd contrib/src && make)";

  postInstall = "
    (cd contrib/src && make install)
    (cd $out/include && ln -s wx-*/* .)
  ";

  passthru = {inherit gtk compat24 compat26 unicode;};

  enableParallelBuilding = true;

  meta = {
    platforms = stdenv.lib.platforms.all;
  };
}
