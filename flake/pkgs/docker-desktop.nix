{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,

  bintools,
  dpkg,

  # Runtime dependencies
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  gtk4,
  libdrm,
  libgbm,
  libGL,
  libglvnd,
  libkrb5,
  libpng,
  libpulseaudio,
  libsecret,
  libX11,
  libxcb,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libxshmfence,
  libXtst,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  udev,
  vulkan-loader,
  wayland,
  xdg-utils,

  # Optional dependencies
  pulseSupport ? true,
  libvaSupport ? true,
  libva,

  # Build dependencies
  libseccomp,
  libcap_ng,
}:

let
  pname = "docker-desktop";
  version = "4.34.0";
  revision = 165256;

  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    gtk4
    libdrm
    libgbm
    libGL
    libglvnd
    libkrb5
    libpng
    libsecret
    libX11
    libxcb
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXScrnSaver
    libxshmfence
    libXtst
    libxkbcommon
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    udev
    vulkan-loader
    wayland
  ]
  ++ lib.optional pulseSupport libpulseaudio
  ++ lib.optional libvaSupport libva;

in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl {
    url = "https://desktop.docker.com/linux/main/amd64/${toString revision}/${pname}-amd64.deb?utm_source=nixpkgs";
    hash = "sha256-qFepUUftBj7GgM2ZIiY8GjhAy16RRPjg2oW1pgbSYYk=";
  };

  # Don't strip, it might break the electron app
  dontStrip = true;
  dontPatchELF = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    dpkg
  ];

  buildInputs = [
    # Core dependencies for autoPatchelfHook
    libseccomp
    libcap_ng
    alsa-lib
    nss
    gtk3
    gtk4
    mesa
    glib
    libsecret
  ]
  ++ deps;

  runtimeDependencies = [
    (lib.getLib systemd)
    fontconfig.lib
    wayland
    libsecret
  ];

  unpackPhase = ''
    runHook preUnpack
    ${lib.getExe' bintools "ar"} x $src
    tar xf data.tar.xz
    runHook postUnpack
  '';

  # Don't run gappsWrapperArgs setup since we removed wrapGAppsHook3
  dontWrapGApps = true;

  desktopItems = [
    (makeDesktopItem {
      name = "docker-desktop";
      exec = "docker-desktop";
      icon = "docker-desktop";
      desktopName = "Docker Desktop";
      comment = "Docker Desktop";
      genericName = "Container Management";
      categories = [
        "Development"
        "System"
      ];
      startupWMClass = "Docker Desktop";
      startupNotify = true;
    })
  ];

  installPhase = ''
    runHook preInstall

    # Create output directories
    mkdir -p $out/{bin,share}

    # Copy application files
    cp -r opt/docker-desktop $out/share/docker-desktop
    cp -r usr/share/* $out/share/ 2>/dev/null || true
    cp -r usr/lib/docker/cli-plugins $out/share/docker-desktop/cli-plugins 2>/dev/null || true

    # Copy systemd user service if it exists
    if [ -d usr/lib/systemd ]; then
      mkdir -p $out/share/systemd
      cp -r usr/lib/systemd/* $out/share/systemd/ 2>/dev/null || true
    fi

    # Install icons - check multiple possible locations
    if [ -f $out/share/docker-desktop/share/icon.png ]; then
      install -Dm644 $out/share/docker-desktop/share/icon.png \
        $out/share/icons/hicolor/512x512/apps/docker-desktop.png
      install -Dm644 $out/share/docker-desktop/share/icon.png \
        $out/share/pixmaps/docker-desktop.png
    elif [ -f $out/share/docker-desktop/share/icon.original.png ]; then
      install -Dm644 $out/share/docker-desktop/share/icon.original.png \
        $out/share/icons/hicolor/512x512/apps/docker-desktop.png
      install -Dm644 $out/share/docker-desktop/share/icon.original.png \
        $out/share/pixmaps/docker-desktop.png
    elif [ -f $out/share/docker-desktop/resources/assets/app/icon.png ]; then
      install -Dm644 $out/share/docker-desktop/resources/assets/app/icon.png \
        $out/share/icons/hicolor/512x512/apps/docker-desktop.png
      install -Dm644 $out/share/docker-desktop/resources/assets/app/icon.png \
        $out/share/pixmaps/docker-desktop.png
    else
      echo "Warning: No icon found, creating a placeholder"
      mkdir -p $out/share/icons/hicolor/512x512/apps $out/share/pixmaps
    fi

    # Replace bundled vulkan-loader with system one
    if [ -f $out/share/docker-desktop/libvulkan.so.1 ]; then
      rm -f $out/share/docker-desktop/libvulkan.so.1
      ln -s ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 $out/share/docker-desktop/libvulkan.so.1
    fi

    runHook postInstall
  '';

  rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;
  binpath = lib.makeBinPath (deps ++ [ xdg-utils ]);

  postFixup = ''
    # Create wrapper for main Docker Desktop executable
    makeWrapper "$out/share/docker-desktop/Docker Desktop" "$out/bin/docker-desktop" \
      --prefix LD_LIBRARY_PATH : "$rpath" \
      --prefix PATH : "$binpath" \
      --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --set CHROME_WRAPPER "docker-desktop"

    # Create wrappers for CLI tools
    for tool in docker-desktop docker-credential-pass; do
      if [ -f "$out/share/docker-desktop/bin/$tool" ]; then
        makeWrapper "$out/share/docker-desktop/bin/$tool" "$out/bin/$tool" \
          --prefix LD_LIBRARY_PATH : "$rpath" \
          --prefix PATH : "$binpath"
      fi
    done

    # Create wrappers for Docker CLI plugins
    if [ -d "$out/share/docker-desktop/cli-plugins" ]; then
      mkdir -p $out/bin
      for plugin in $out/share/docker-desktop/cli-plugins/*; do
        if [ -f "$plugin" ] && [ -x "$plugin" ]; then
          plugin_name=$(basename "$plugin")
          makeWrapper "$plugin" "$out/bin/$plugin_name" \
            --prefix LD_LIBRARY_PATH : "$rpath" \
            --prefix PATH : "$binpath"
        fi
      done
    fi

    # Patch main executable - only if they're dynamically linked
    for elf in "$out/share/docker-desktop/Docker Desktop" \
               "$out/share/docker-desktop/chrome_crashpad_handler" \
               "$out/share/docker-desktop/chrome-sandbox"; do
      if [ -f "$elf" ]; then
        echo "Patching $elf"
        if ldd "$elf" >/dev/null 2>&1; then
          patchelf --set-rpath "$rpath" "$elf" 2>/dev/null || true
          patchelf --set-interpreter ${bintools.dynamicLinker} "$elf" 2>/dev/null || true
        else
          echo "Skipping $elf (statically linked)"
        fi
      fi
    done

    # Patch .so files in the main directory
    for so in $out/share/docker-desktop/lib*.so*; do
      if [ -f "$so" ] && [ ! -L "$so" ]; then
        echo "Patching library $so"
        if ldd "$so" >/dev/null 2>&1; then
          patchelf --set-rpath "$rpath" "$so" 2>/dev/null || true
        else
          echo "Skipping $so (not dynamically linked)"
        fi
      fi
    done

    # Patch binaries in bin directory - only if dynamically linked
    if [ -d "$out/share/docker-desktop/bin" ]; then
      for bin in $out/share/docker-desktop/bin/*; do
        if [ -f "$bin" ] && [ -x "$bin" ]; then
          echo "Patching binary $bin"
          if ldd "$bin" >/dev/null 2>&1; then
            patchelf --set-rpath "$rpath" "$bin" 2>/dev/null || true
            patchelf --set-interpreter ${bintools.dynamicLinker} "$bin" 2>/dev/null || true
          else
            echo "Skipping $bin (statically linked)"
          fi
        fi
      done
    fi

    # Patch CLI plugins - only if dynamically linked
    if [ -d "$out/share/docker-desktop/cli-plugins" ]; then
      for plugin in $out/share/docker-desktop/cli-plugins/*; do
        if [ -f "$plugin" ] && [ -x "$plugin" ]; then
          echo "Patching plugin $plugin"
          if ldd "$plugin" >/dev/null 2>&1; then
            patchelf --set-rpath "$rpath" "$plugin" 2>/dev/null || true
            patchelf --set-interpreter ${bintools.dynamicLinker} "$plugin" 2>/dev/null || true
          else
            echo "Skipping $plugin (statically linked)"
          fi
        fi
      done
    fi

    # Fix desktop files to point to our wrapper - be more flexible with patterns
    for desktop in $out/share/applications/*.desktop; do
      if [ -f "$desktop" ]; then
        sed -i -e 's|/opt/docker-desktop/bin/docker-desktop|'$out'/bin/docker-desktop|g' \
               -e 's|/usr/bin/docker-desktop|'$out'/bin/docker-desktop|g' \
               -e 's|Exec=docker-desktop|Exec='$out'/bin/docker-desktop|g' \
               "$desktop" || true
      fi
    done
  '';

  meta = with lib; {
    description = "Docker Desktop - The easiest way to get started with Docker on your machine";
    homepage = "https://www.docker.com/products/docker-desktop";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "docker-desktop";
  };
}
