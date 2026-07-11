{
  stdenvNoCC,
  kdePackages,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plasma-applications-schema";
  version = kdePackages.plasma-workspace.version;

  src = kdePackages.plasma-workspace.out;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/etc/xdg/menus
    cp ${finalAttrs.src}/etc/xdg/menus/* $out/etc/xdg/menus/
    runHook postInstall
  '';
})
