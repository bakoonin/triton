{ stdenv
, cmake
, fetchurl
, gettext
, intltool
, lib
, ninja

, db
, gcr
, glib
#, gnome-online-accounts
, gobject-introspection
, gperf
, gsettings-desktop-schemas
, gtk
, icu
, kerberos
, libaccounts-glib
, libgdata
, libgweather
, libical
, libsecret
, libsoup
, libxml2
, openldap
, nspr
, nss
, p11-kit
, python3
, sqlite
, zlib

, channel
}:

let
  inherit (lib)
    boolOn;

  sources = {
    "3.28" = {
      version = "3.28.1";
      sha256 = "6b04fc1adaba0541546267a77f1bc5aa549fe85eb9933492fdf994c69fa36989";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "evolution-data-server-${source.version}";

  src = fetchurl {
    url = "mirror://gnome/sources/evolution-data-server/${channel}/"
      + "${name}.tar.xz";
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    cmake
    gettext
    intltool
    ninja
  ];

  buildInputs = [
    db
    gcr
    glib
    #gnome-online-accounts
    gobject-introspection
    gperf
    gsettings-desktop-schemas
    gtk
    icu
    kerberos
    libaccounts-glib
    libgdata
    libgweather
    libical
    libsecret
    libsoup
    libxml2
    nspr
    nss
    openldap
    p11-kit
    python3
    sqlite
    zlib
  ];

  cmakeFlags = [
    "-DENABLE_GTK=${boolOn (gtk != null)}"
    "-DENABLE_OAUTH2=OFF"  # Remove dependency on webkit
    "-DENABLE_GOOGLE_AUTH=OFF"  # Remove dependency on webkit
    "-DENABLE_EXAMPLES=OFF"
    "-DENABLE_GOA=OFF"  # Remove dependency on webkit
    "-DENABLE_UOA=OFF"  # Remove dependency on webkit
    "-DENABLE_BACKEND_PER_PROCESS=ON"
    "-DENABLE_WEATHER=${boolOn (libgweather != null)}"
    "-DENABLE_BROKEN_SPOOL=OFF"
    "-DENABLE_GOOGLE=OFF"  # Remove dependency on webkit
    "-DENABLE_VALA_BINDINGS=OFF"
    # "-DWITH_DBUS_SERVICE_DIR"
    # "-DWITH_SYSTEMDUSERUNITDIR"
    # "-DWITH_GOOGLE_CLIENT_ID"
    # "-DWITH_GOOGLE_CLIENT_SECRET"
    "-DWITH_LIBDB=${if (db != null) then "${db}" else "OFF"}"
    # "-DWITH_LIBDB_CFLAGS"
    # "-DWITH_LIBDB_LIBS"
  ];

  CXXFLAGS = [
    # http://site.icu-project.org/download/61#TOC-Migration-Issues
    "-DU_USING_ICU_NAMESPACE=1"
  ];

  buildDirCheck = false;  # FIXME

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      sha256Url = "https://download.gnome.org/sources/evolution-data-server/"
        + "${channel}/${name}.sha256sum";
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Evolution groupware backend";
    homepage = https://wiki.gnome.org/Apps/Evolution;
    license = with licenses; [
      lgpl2
      lgpl3
      bsd3
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
