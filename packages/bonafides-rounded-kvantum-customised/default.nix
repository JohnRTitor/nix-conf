{
  stdenvNoCC,
  lib,
  replaceVars,
  colors ? null,
}:

let
  defaultColors = {
    base00 = "1d212f";
    base01 = "242938";
    base02 = "33384a";
    base03 = "6e738c";
    base04 = "bdc2d5";
    base05 = "d6dbf1";
    base0D = "6690bc";
    base0E = "8467a8";
  };
  themeColors = if colors != null then colors else defaultColors;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bonafides-rounded-kvantum";
  version = "1.0";

  src = ./src;

  dontBuild = true;

  postPatch = ''
    cp ${
      replaceVars ./src/BonaFides-Rounded-Kvantum/BonaFides-Rounded-Kvantum.kvconfig {
        inherit (themeColors)
          base00
          base01
          base02
          base03
          base04
          base05
          base0D
          base0E
          ;
      }
    } BonaFides-Rounded-Kvantum/BonaFides-Rounded-Kvantum.kvconfig

    cp ${
      replaceVars ./src/BonaFides-Rounded-Kvantum/BonaFides-Rounded-Kvantum.svg {
        inherit (themeColors) base00;
      }
    } BonaFides-Rounded-Kvantum/BonaFides-Rounded-Kvantum.svg
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/Kvantum
    cp -r BonaFides-Rounded-Kvantum $out/share/Kvantum/
    runHook postInstall
  '';

  meta = {
    description = "BonaFides Rounded Kvantum theme (customised)";
    maintainers = with lib.maintainers; [ johnrtitor ];
    platforms = lib.platforms.linux;
  };
})
