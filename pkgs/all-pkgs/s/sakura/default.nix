{ stdenv
, cmake
, fetchurl
, lib
, makeWrapper
, perl

, adwaita-icon-theme
, gdk-pixbuf
, glib
, gtk_3
, libx11
, shared-mime-info
, vte
}:

let
  version = "3.5.0";
in
stdenv.mkDerivation rec {
  name = "sakura-${version}";

  src = fetchurl {
    url = "https://launchpad.net/sakura/trunk/${version}/+download/"
      + "${name}.tar.bz2";
    sha256 = "eb30ede41083fda2b07c6a3b7393150f48867e81d28ef70b15824740cab00c3a";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    perl
  ];

  buildInputs = [
    adwaita-icon-theme
    glib
    gtk_3
    libx11
    vte
  ];

  preFixup = ''
    wrapProgram $out/bin/sakura \
      --set GDK_PIXBUF_MODULE_FILE "${gdk-pixbuf.loaders.cache}" \
      --prefix XDG_DATA_DIRS : "${shared-mime-info}/share" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
  '';

  meta = with lib; {
    description = "A terminal emulator based on GTK and VTE";
    homepage = http://www.pleyades.net/david/projects/sakura;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
