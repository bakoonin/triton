{ stdenv
, fetchTritonPatch
, fetchurl
, gettext
, intltool
, makeWrapper

, adwaita-icon-theme
, atk
, dbus-glib
, dconf
, exempi
, gdk-pixbuf
, glib
, gnome-desktop
, gobject-introspection
, gsettings-desktop-schemas
, gtk3
, gvfs
, libexif
, libnotify
, librsvg
, libunique
, libxml2
, pango
, shared_mime_info
, tracker
, xorg
}:

let
  inherit (stdenv.lib)
    enFlag;
in

stdenv.mkDerivation rec {
  name = "nautilus-${version}";
  versionMajor = "3.20";
  versionMinor = "1";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "mirror://gnome/sources/nautilus/${versionMajor}/${name}.tar.xz";
    sha256 = "f2a907b994026412a7ed7c8145d4ab4f886ac87e780353b967473305a35e81e8";
  };

  nativeBuildInputs = [
    gettext
    intltool
    makeWrapper
  ];

  buildInputs = [
    adwaita-icon-theme
    atk
    dbus-glib
    dconf
    exempi
    gdk-pixbuf
    glib
    gnome-desktop
    gobject-introspection
    gsettings-desktop-schemas
    gtk3
    gvfs
    libexif
    libnotify
    librsvg
    libunique
    libxml2
    pango
    shared_mime_info
    tracker
    xorg.libX11
  ];

  patches = [
    (fetchTritonPatch {
      rev = "734f89c9d36781e3f50f30dc9aa33d071136dbd0";
      file = "nautilus/extension_dir.patch";
      sha256 = "ebd28b1f94106562574bb43884565761a34f233bcefa0ab516bf82e7691ee764";
    })
  ];

  postPatch = ''
    sed -i configure \
      -e 's/DISABLE_DEPRECATED_CFLAGS=.*/DISABLE_DEPRECATED_CFLAGS=/'
  '';

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-schemas-compile"
    "--enable-nls"
    "--disable-gtk-doc"
    "--disable-gtk-doc-html"
    "--disable-gtk-doc-pdf"
    "--disable-profiling"
    "--enable-nst-extension"
    (enFlag "libexif" (libexif != null) null)
    "--enable-xmp"
    "--disable-selinux"
    # Flag is not a proper boolean
    #"--disable-empty-view"
    "--enable-packagekit"
    "--enable-more-warnings"
    (enFlag "tracker" (tracker != null) null)
    (enFlag "introspection" (gobject-introspection != null) null)
    "--disable-update-mimedb"
  ];

  preFixup = ''
    wrapProgram $out/bin/nautilus \
      --set 'GDK_PIXBUF_MODULE_FILE' "$GDK_PIXBUF_MODULE_FILE" \
      --set 'GSETTINGS_BACKEND' 'dconf' \
      --prefix 'GIO_EXTRA_MODULES' : "$GIO_EXTRA_MODULES" \
      --prefix 'PATH' : "${gvfs}/bin" \
      --prefix 'XDG_DATA_DIRS' : "$GSETTINGS_SCHEMAS_PATH" \
      --prefix 'XDG_DATA_DIRS' : "$out/share" \
      --prefix 'XDG_DATA_DIRS' : "${shared_mime_info}/share" \
      --prefix 'XDG_DATA_DIRS' : "$XDG_ICON_DIRS"
  '';

  meta = with stdenv.lib; {
    description = "A file manager for the GNOME desktop";
    homepage = https://wiki.gnome.org/Apps/Nautilus;
    license = with licenses; [
      fdl11
      gpl2Plus
      lgpl2Plus
    ];
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
