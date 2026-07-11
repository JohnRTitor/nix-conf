{
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "utterly-sweet-kvantum";
  version = "1.0";

  src = ./src;

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/Kvantum
    cp -r ${finalAttrs.src}/* $out/share/Kvantum
    runHook postInstall
  '';

  meta = {
    description = "Utterly Sweet Kvantum theme";
    maintainers = with lib.maintainers; [ johnrtitor ];
    platforms = lib.platforms.linux;
  };
})
