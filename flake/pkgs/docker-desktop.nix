{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, libseccomp
, libcap_ng
, alsa-lib
, nss
, gtk3
, mesa
, lib
, bintools
, tree
# Additional dependencies for Chromium/Electron apps
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gcc-unwrapped
, gdk-pixbuf
, glib
, gtk4
, libdrm
, libglvnd
, libkrb5
, libX11
, libxcb
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libxkbcommon
, libXrandr
, libXrender
, libXScrnSaver
, libxshmfence
, libXtst
, libgbm
, nspr
, pango
, pipewire
, vulkan-loader
, wayland
# Command line programs
, coreutils
, systemd
, libexif
, pciutils
# Additional dependencies
, curl
, liberation_ttf
, util-linux
, wget
, xdg-utils
, flac
, harfbuzz
, icu
, libopus
, libpng
, snappy
, speechd-minimal
, bzip2
, libcap
, libpulseaudio
, pulseSupport ? true
, adwaita-icon-theme
, gsettings-desktop-schemas
, libva
, libvaSupport ? true
, addDriverRunpath
# For QT support
, qt6
}:

let
  opusWithCustomModes = libopus.override { withCustomModes = true; };

  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bzip2
    cairo
    coreutils
    cups
    curl
    dbus
    expat
    flac
    fontconfig
    freetype
    gcc-unwrapped.lib
    gdk-pixbuf
    glib
    harfbuzz
    icu
    libcap
    libcap_ng
    libdrm
    liberation_ttf
    libexif
    libglvnd
    libkrb5
    libpng
    libseccomp
    libX11
    libxcb
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libxkbcommon
    libXrandr
    libXrender
    libXScrnSaver
    libxshmfence
    libXtst
    libgbm
    mesa
    nspr
    nss
    opusWithCustomModes
    pango
    pciutils
    pipewire
    snappy
    speechd-minimal
    systemd
    util-linux
    vulkan-loader
    wayland
    wget
  ]
  ++ lib.optional pulseSupport libpulseaudio
  ++ lib.optional libvaSupport libva
  ++ [
    gtk3
    gtk4
    qt6.qtbase
    qt6.qtwayland
  ];

in stdenv.mkDerivation rec {
  pname = "docker-desktop";
  version = "4.34.0";
  revision = 165256;

  src = fetchurl {
    url = "https://desktop.docker.com/linux/main/amd64/${toString revision}/${pname}-amd64.deb?utm_source=nixpkgs";
    hash = "sha256-qFepUUftBj7GgM2ZIiY8GjhAy16RRPjg2oW1pgbSYYk=";
  };

  # With strictDeps on, some shebangs were not being patched correctly
  strictDeps = false;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    tree
    qt6.wrapQtAppsHook
  ];

  buildInputs = deps ++ [
    # needed for XDG_ICON_DIRS
    adwaita-icon-theme
    glib
    gtk3
    gtk4
    # needed for GSETTINGS_SCHEMAS_PATH
    gsettings-desktop-schemas
  ];

  unpackPhase = ''
    runHook preUnpack
    ${lib.getExe' bintools "ar"} x $src
    tar xf data.tar.xz
    runHook postUnpack
  '';

  rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;
  binpath = lib.makeBinPath deps;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share $out/lib

    # Copy main application files
    cp -r opt/docker-desktop $out/share/
    
    # Copy CLI plugins and other utilities
    cp -r usr/lib/* $out/lib/
    cp -r usr/bin/* $out/bin/
    
    # Copy desktop files and other shared resources
    cp -r usr/share/* $out/share/

    # Replace bundled vulkan-loader
    rm -f $out/share/docker-desktop/libvulkan.so.1
    ln -s ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 $out/share/docker-desktop/libvulkan.so.1

    # Fix desktop files to point to our wrapper
    substituteInPlace $out/share/applications/docker-desktop.desktop \
      --replace-fail "/opt/docker-desktop/bin/docker-desktop" "$out/bin/docker-desktop" \
      --replace-fail "/opt/docker-desktop/share/icon.original.png" "$out/share/docker-desktop/share/icon.original.png"
    
    substituteInPlace $out/share/applications/docker-desktop-uri-handler.desktop \
      --replace-fail "/opt/docker-desktop/bin/com.docker.url-handler" "$out/share/docker-desktop/bin/com.docker.url-handler"

    # Create wrapper for the main Docker Desktop application
    makeWrapper "$out/share/docker-desktop/Docker Desktop" "$out/bin/docker-desktop" \
      --prefix QT_PLUGIN_PATH : "${qt6.qtbase}/lib/qt-6/plugins" \
      --prefix QT_PLUGIN_PATH : "${qt6.qtwayland}/lib/qt-6/plugins" \
      --prefix NIXPKGS_QT6_QML_IMPORT_PATH : "${qt6.qtwayland}/lib/qt-6/qml" \
      --prefix LD_LIBRARY_PATH : "$rpath" \
      --prefix PATH : "$binpath" \
      --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH:${addDriverRunpath.driverLink}/share" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    # Create wrapper for docker-desktop CLI
    if [ -f "$out/share/docker-desktop/bin/docker-desktop" ]; then
      makeWrapper "$out/share/docker-desktop/bin/docker-desktop" "$out/bin/docker-desktop-cli" \
        --prefix LD_LIBRARY_PATH : "$rpath" \
        --prefix PATH : "$binpath"
    fi

    # Make sure that libGL and libvulkan are found by ANGLE libGLESv2.so
    for lib in $out/share/docker-desktop/lib*GL* $out/share/docker-desktop/libEGL.so $out/share/docker-desktop/libGLESv2.so; do
      if [ -f "$lib" ]; then
        patchelf --set-rpath $rpath "$lib"
      fi
    done

    # Patch ELF files in the main application directory
    for elf in $out/share/docker-desktop/{chrome,chrome-sandbox,chrome_crashpad_handler,"Docker Desktop"}; do
      if [ -f "$elf" ]; then
        patchelf --set-rpath $rpath "$elf" || true
        patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} "$elf" || true
      fi
    done

    # Patch native Node modules
    find $out/share/docker-desktop/resources/app.asar.unpacked -name "*.node" -type f | while read node_module; do
      patchelf --set-rpath $rpath "$node_module" || true
    done

    # Patch binaries in the bin directory
    for elf in $out/share/docker-desktop/bin/*; do
      if [ -f "$elf" ] && [ -x "$elf" ]; then
        patchelf --set-rpath $rpath "$elf" || true
        patchelf --set-interpreter ${stdenv.cc.bintools.dynamicLinker} "$elf" || true
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Docker Desktop - The fastest way to containerize applications";
    homepage = "https://www.docker.com/products/docker-desktop";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    mainProgram = "docker-desktop";
  };
}