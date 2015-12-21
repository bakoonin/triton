{ fetchurl, stdenv, pkgconfig, libdaemon, dbus, perl, perlXMLParser
, expat, gettext, intltool, glib, libiconv
, qt4 ? null
, qt4Support ? false }:

assert qt4Support -> qt4 != null;

stdenv.mkDerivation rec {
  name = "avahi-0.6.31";

  src = fetchurl {
    url = "${meta.homepage}/download/${name}.tar.gz";
    sha256 = "0j5b5ld6bjyh3qhd2nw0jb84znq0wqai7fsrdzg7bpg24jdp2wl3";
  };

  patches = [ ./no-mkdir-localstatedir.patch ];

  buildInputs = [ libdaemon dbus perl perlXMLParser glib expat libiconv ]
    ++ (stdenv.lib.optional qt4Support qt4);

  nativeBuildInputs = [ pkgconfig gettext intltool ];

  configureFlags =
    [ "--disable-qt3" "--disable-gdbm" "--disable-mono"
      "--disable-gtk" "--disable-gtk3"
      "--enable-compat-libdns_sd"
      "--enable-compat-howl"
      "--${if qt4Support then "enable" else "disable"}-qt4"
      "--disable-python" "--localstatedir=/var" "--with-distro=none" ]
    # autoipd won't build on darwin
    ++ stdenv.lib.optional stdenv.isDarwin "--disable-autoipd";

  preBuild = stdenv.lib.optionalString stdenv.isDarwin ''
    sed -i '20 i\
    #define __APPLE_USE_RFC_2292' \
    avahi-core/socket.c
  '';

  meta = with stdenv.lib; {
    description = "mDNS/DNS-SD implementation";
    homepage    = http://avahi.org;
    license     = licenses.lgpl2Plus;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ lovek323 ];

    longDescription = ''
      Avahi is a system which facilitates service discovery on a local
      network.  It is an implementation of the mDNS (for "Multicast
      DNS") and DNS-SD (for "DNS-Based Service Discovery")
      protocols.
    '';
  };
}
