{ stdenv
, fetchurl
, makeWrapper
, yasm

, alsaLib
, bzip2
#, cairo
, dbus
, dbus_glib
#, ffmpeg
, file
, fontconfig
, freetype
, glib
, gst-plugins-base
, gstreamer
, gtk2
, gtk3
, hunspell
, icu
, jemalloc
, libevent
, libffi
, libIDL
, libjpeg
, libnotify
, libpng
#, libproxy
, libpulseaudio
, libstartup_notification
, libvpx
, libwebp
, mesa
, nspr
, nss
, pango
, perl
, pixman
, pysqlite
, python
, sqlite
, unzip
, xorg
, zip
, zlib

, channel ? "stable"

, debugBuild ? false

# If you want the resulting program to be called "Firefox" instead of
# "nightly", enable this option.  However, the resulting binaries may
# not be re-distributed without permission from the Mozilla Foundation,
# see http://www.mozilla.org/foundation/trademarks/.
, enableOfficialBranding ? false
}:

with {
  inherit (stdenv)
    isLinux;
  inherit (stdenv.lib)
    optionals
    versionAtLeast;
  inherit (builtins.getAttr channel (import ./sources.nix))
    version
    sha512;
};

assert stdenv.cc ? libc && stdenv.cc.libc != null;
assert (channel == "stable" || channel == "esr");

stdenv.mkDerivation rec {
  name = "firefox${if channel != "stable" then "-${channel}" else ""}-${version}";

  src = fetchurl {
    url =
      let
        ext =
          if versionAtLeast version "41.0" then
            "xz"
          else
            "bz2";
      in
      "https://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${version}/"
    + "source/firefox-${version}.source.tar.${ext}";
    inherit sha512;
  };

  nativeBuildInputs = [
    makeWrapper
    yasm
  ];

  buildInputs = [
    alsaLib
    bzip2
    #cairo
    dbus
    dbus_glib
    #ffmpeg
    file
    fontconfig
    freetype
    glib
    gst-plugins-base
    gstreamer
    gtk2
    gtk3
    hunspell
    icu
    jemalloc
    libevent
    libffi
    libIDL
    libjpeg
    libnotify
    libpng
    #libproxy
    libpulseaudio
    libstartup_notification
    libvpx
    libwebp
    mesa
    nspr
    nss
    pango
    perl
    pixman
    pysqlite
    python
    sqlite
    unzip
    xorg.libXi
    xorg.libX11
    xorg.libXrender
    xorg.libXft
    xorg.libXt
    xorg.libXScrnSaver
    xorg.scrnsaverproto
    xorg.pixman
    xorg.libXext
    xorg.xextproto
    xorg.libXcomposite
    xorg.libXdamage
    zip
    zlib
  ];

  # Firefox's bastardized autoconf script does not treat all flags
  # as booleans, so only pass flags used.
  configureFlags =
    optionals (!debugBuild) [
      "--enable-release"
    ] ++ [
      "--with-x"
    ] ++ optionals debugBuild [
      "--enable-profiling"
      "--enable-debug"
      "--enable-debug-symbols"
    ] ++ [
      "--enable-pie"
      "--with-pthreads"
    ] ++ optionals (nspr != null) [
      "--with-system-nspr"
      #"--enable-posix-nspr-emulation"
    ] ++ optionals (libevent != null) [
      "--with-system-libevent"
    ] ++ optionals (nss != null) [
      "--with-system-nss"
    ] ++ optionals (!isLinux && libjpeg != null) [
      # Enable libjpeg for platforms that don't support libjpeg-turbo
      "--with-system-jpeg"
    ] ++ optionals (zlib != null) [
      "--with-system-zlib"
    ] ++ optionals (bzip2 != null) [
      "--with-system-bz2"
    ] ++ optionals (libpng != null) [
      "--with-system-png"
    ] ++ optionals (hunspell != null) [
      "--enable-system-hunspell"
    ] ++ optionals (libffi != null) [
      "--enable-system-ffi"
    ] ++ [
      # Linking fails with shared js
      #"--enable-shared-js"
      #"--with-java-bin-path"
      "--enable-application=browser"
    ] ++ optionals enableOfficialBranding [
      "--enable-official-branding"
    ] ++ optionals (/*cairo != null &&*/ gtk3 != null) [
      "--enable-default-toolkit=cairo-gtk3"
      #"--without-x"
    ] ++ optionals (libstartup_notification != null) [
      "--enable-startup-notification"
    ] ++ [
      "--disable-gconf"
      #"--enable-libproxy"
      #"--enable-gnomeui" # ??? gnome2 ???
      "--enable-raw"
      #"--enable-eme"
    ] ++ optionals (libvpx != null) [
      "--with-system-libvpx"
    ] ++ optionals (alsaLib != null) [
      "--enable-alsa"
    ] ++ optionals (gstreamer != null && gst-plugins-base != null) [
      "--enable-gstreamer=1.0"
    ] ++ [
      "--disable-crashreporter"
    ] ++ optionals (isLinux && libjpeg != null)[
      "--enable-libjpeg-turbo"
    ] ++ [
      #"--enable-tree-freetype"
      #"--enable-maintenance-service"
      "--disable-updater"
      "--disable-tests"
      "--enable-content-sandbox"
    ] ++ optionals (sqlite != null) [
      "--enable-system-sqlite"
    ] ++ [
      "--enable-safe-browsing"
      "--enable-url-classifier"
      "--enable-optimize"
      "--enable-approximate-location"
    ] ++ optionals (jemalloc != null) [
      "--enable-jemalloc"
    ] ++ [
      "--enable-strip"
      #"--enable-b2g-ril"
      #"--enable-b2g-bt"
      #"--enable-nfc"
      #"--enable-synth-pico"
      #"--enable-b2g-camera"
      #"--enable-system-cairo"
      #"--enable-xterm-updates"
      "--enable-skia"
    ] /*++ optionals (cairo != null) [
      # From firefox-40, using system cairo causes firefox to crash
      # frequently when it is doing background rendering in a tab.
      "--enable-system-cairo"
    ]*/ ++ optionals (pixman != null) [
      "--enable-system-pixman"
    ] ++ [
      #"--enable-necko-protocols={http,ftp,default,all,none}"
      "--disable-necko-wifi"
    ] ++ optionals (icu != null) [
      "--with-system-icu"
    ];

  preConfigure = ''
    mkdir -v ../objdir
    cd ../objdir
    if [ -e ../${name} ] ; then
      configureScript=../${name}/configure
    else
      configureScript=../mozilla-*/configure
    fi
  '';

  preInstall =
    /* The following is needed for startup cache creation
       on grsecurity kernels. */ ''
      paxmark m ../objdir/dist/bin/xpcshell
    '';

  postInstall =
    /* For grsecurity kernels */ ''
      paxmark m $out/lib/${name}/{firefox,firefox-bin,plugin-container}
    '' +
    /* Remove SDK cruft. */ ''
      rm -rvf $out/share/idl $out/include $out/lib/firefox-devel-*
    '' +
    /* GTK3: argv[0] must point to firefox itself */ ''
      wrapProgram "$out/bin/firefox" \
        --argv0 "$out/bin/.firefox-wrapped" \
        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH" \
        --prefix XDG_DATA_DIRS : "$out/share" \
        --suffix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
    '' +
    /* Basic test */ ''
      "$out/bin/firefox" --version
    '';

  passthru = {
    inherit
      gtk2
      nspr
      version;
    isFirefox3Like = true;
  };

  meta = with stdenv.lib; {
    description = "Firefox Web Browser";
    homepage = http://www.mozilla.com/en-US/firefox/;
    license = with licenses; [
      gpl2
      lgpl21
      mpl20
    ];
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
