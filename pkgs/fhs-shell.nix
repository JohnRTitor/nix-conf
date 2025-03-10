{ pkgs, ... }:
let
  base = pkgs.appimageTools.defaultFhsEnvArgs;
in
pkgs.buildFHSEnv (
  base
  // {
    name = "fhs"; # provides fhs command to enter in a FHS environment
    targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [ pkgs.pkg-config ];
    profile = "export FHS=1";
    runScript = "$SHELL";
    extraOutputsToInstall = [ "dev" ];
  }
)
