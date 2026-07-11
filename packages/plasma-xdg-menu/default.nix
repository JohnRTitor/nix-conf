{
  stdenvNoCC,
  kdePackages,
  lib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plasma-xdg-menu";
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

  meta = {
    description = "Plasma XDG menus";
    maintainers = with lib.maintainers; [ johnrtitor ];
    platforms = lib.platforms.linux;
  };
})
