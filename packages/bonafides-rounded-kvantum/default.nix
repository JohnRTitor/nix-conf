{
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bonafides-rounded-kvantum";
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
})
