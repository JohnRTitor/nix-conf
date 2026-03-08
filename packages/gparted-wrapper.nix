{
  lib,
  pkgs,
  ...
}:
# Wrapper for GParted to run under Wayland
let
  xhost = lib.getExe pkgs.xhost;
  gparted = lib.getExe pkgs.gparted;
in
pkgs.writeShellScriptBin "gparted" ''
  if [[ $EUID -ne 0 ]]; then
    echo "Should be launched as root! Exiting......."
    exit 1
  fi
  ${xhost} + && \
  ${gparted} "$@" && \
  ${xhost} -
''
